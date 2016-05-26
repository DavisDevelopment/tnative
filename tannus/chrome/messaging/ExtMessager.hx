package tannus.chrome.messaging;

import tannus.ds.Object;
import tannus.ds.Memory;
import tannus.ds.Maybe;
import tannus.io.Ptr;
import tannus.io.Signal;
import tannus.chrome.Runtime;
import tannus.chrome.Tabs;
import tannus.chrome.Tab;
import tannus.messaging.*;
import tannus.messaging.Message;
import Std.*;

import tannus.chrome.messaging.BGServer in Server;

class ExtMessager extends Messager {
	/* Constructor Function */
	public function new(?server:Bool=false):Void {
		super();
		is_server = server;
		tab = null;
		_connected = new Signal();

		__init();
		instance = this;
	}

/* === Instance Methods === */

	/**
	  * Initialize [this] Messager
	  */
	private function __init():Void {
		if (is_server) {
			/**
			  * When chrome.runtime fires the 'onMessage' Event
			  */
			Runtime.onMessage(function( msg ) {
				/* get the Address of the Sender */
				var senderAddress:Address = Address.fromChromeMessage( msg );

				/* check that [msg] is a valid SafeMessage Object */
				if (SafeMessage.isSafeMessage( msg.data )) {
					/* if we're not connected to anything yet */
					if (peerAddress == null) {
						//- if [this] Messager is in a Pool
						if ( inPool ) {
							//- ignore input from Tabs we're already connected to
							//var existing = pool.getMessagerByTab( msg.sender.tab.id );
							var existing = pool.getMessagerByAddress( senderAddress );
							if (existing != null) {
								trace( existing );
								return ;
							}
						}

						//- set the [tab] field to that of [msg.sender]
						// tab = msg.sender.tab;
						peerAddress = senderAddress;

						//- dispatch the 'connected' Event
						_connected.call( null );
					}

					/* if we're already connected to something */
					else {
						/* if the Message came from any other Messager than [peer] */
						if (!senderAddress.equals( peerAddress )) {
							trace('${senderAddress} != ${peerAddress}');
						}
						/*
						if (msg.sender.tab.value.id != tab.value.id) {
							return ;
						}
						*/
					}

					/* decode the Message object */
					var safe:SafeMessage = (cast msg.data);
					var messg:Message = Message.fromSafe(this, safe);

					/* pull additional address info from the Message itself */
					senderAddress.getMessageInfo( messg );

					/* and plop it right into our sexy-ass Message-handling system */
					receiveFromPeer( messg );
				} 

				trace( senderAddress );
			});

			/* the first time the 'connected' Event is dispatched */
			_connected.once(function(x) {
				/* send the peer metadata */
				send('meta:source', {
					'address' : peerAddress
				});
			});
		}

		/* if we're a "client-side" Messager */
		else {
			/* listen for data from the chrome.runtime.onMessage Event */
			Runtime.onMessage(function( msg ) {
				/* get the Address of the sender */
				var senderAddress:Address = Address.fromChromeMessage( msg );

				/* if [msg] is a valid Message */
				if (SafeMessage.isSafeMessage( msg.data )) {
					/* decode it into a Message object */
					var messg:Message = Message.fromSafe(this, cast msg.data);

					/* get info from the Message object as well */
					senderAddress.getMessageInfo( messg );

					/* whether the Message is from our peer Socket or not */
					var fromPeer:Bool = peerAddress.equals( senderAddress );
					trace('message from peer: $fromPeer');

					/* send it to be handled */
					receiveFromPeer( messg );
				}

				trace( senderAddress );
			});
		}

		on('meta:connect', function(msg) {
			var url:String = cast msg.data['url'];

			send('meta:connected', {'status': true});
		});
	}

	/**
	  * Send Message
	  */
	override private function sendToPeer(msg : Message):Void {
		var safe = msg.safe();

		/* Background Page */
		if ( is_server ) {
			if (peerAddress.app == Runtime.id) {
				peerAddress.tab.sendMessage( safe );
			}
			else {
				Runtime.sendMessage(peerAddress.app, safe);
			}
		}

		/* Content Script */
		else {
			Runtime.sendMessage(peerAddress.app, safe);
		}
	}

	/**
	  * Receive Message
	  */
	override private function receiveFromPeer(msg : Message):Void {
		incoming.call( msg );
		switch (msg.type) {
			/* Standard Message */
			case Normal:
				if (msg.channel != '') {
					var sig:Signal<Message> = chanSig(msg.channel);
					sig.call( msg );
				}

			case Reply:
				var listn = awaitingReply[msg.id];
				if (listn != null) {
					listn(msg.data);
				}

			case Broadcast:
				if (is_server && inPool) {
					var audience = pool.sockets.filter(function(s) return (s != this));
					for (s in audience) {
						s.send(msg.channel, msg.data, msg.reply);
					}
				}

			default:
				throw 'MessageError: Unexpected Message Type "${msg.type}"!';
		}
	}

	/**
	  * Connect to external Socket
	  */
	public function connectToExternal(appid:String, cb:Bool->Void):Void {
		peerAddress = new Address({
			'app': appid,
			'tab': null
		});
		connect( cb );
	}

	/**
	  * Connect to the Background Page of [this] Application
	  */
	public function connectToBackground(cb : Bool->Void):Void {
		peerAddress = new Address({
			'app': Runtime.id,
			'tab': null
		});
		connect( cb );
	}

	/**
	  * Connect to the peer
	  */
	override public function connect(cb : Bool->Void):Void {
		if ( is_server ) {
			if (peerAddress != null) {
				cb( true );
			}
			else {
				_connected.on(function(x) cb(true));
			}
		}
		else {
			super.connect( cb );
		}
	}

	/**
	  * Get the data required by the peer for connection
	  */
	override private function getConnectionData():Object {
		return {
			'url': js.Browser.window.location.href
		};
	}

/* === Computed Instance Fields === */

	private var inPool(get, never):Bool;
	private inline function get_inPool() return (pool != null);

/* === Instance Fields === */

	/* Whether [this] Messager is on the background-page */
	private var is_server : Bool;

	/* (server) The Tab [this] Messager is connected to */
	public var tab : Maybe<Tab>;

	/* the Address of Socket that [this] is connected to */
	public var peerAddress : Null<Address>;

	/*erver) The MessagePool [this] is attached to */
	public var pool : Null<Server>;

	/* (server) The Signal fired when [tab] is declared */
	private var _connected : Signal<Dynamic>;

/* === Static Fields === */

	public static var instance : ExtMessager;
}
