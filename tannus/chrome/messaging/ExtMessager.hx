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
					if (tab == null) {
						//- if [this] Messager is in a Pool
						if ( inPool ) {
							//- ignore input from Tabs we're already connected to
							var existing = pool.getMessagerByTab( msg.sender.tab.id );
							if (existing != null) {
								return ;
							}
						}

						//- set the [tab] field to that of [msg.sender]
						tab = msg.sender.tab;

						//- dispatch the 'connected' Event
						_connected.call( null );
					}

					/* if we're already connected to something */
					else {
						/* if the Message came from any other Messager than [peer] */
						if (msg.sender.tab.value.id != tab.value.id) {
							return ;
						}
					}

					/* decode the Message object */
					var safe:SafeMessage = (cast msg.data);
					var messg:Message = Message.fromSafe(this, safe);
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
					'tab': tab.value.id
				});
			});
		}

		/* if we're a "client-side" Messager */
		else {
			/* listen for data from the chrome.runtime.onMessage Event */
			Runtime.onMessage(function( msg ) {
				/* if [msg] is a valid Message */
				if (SafeMessage.isSafeMessage( msg.data )) {
					/* decode it into a Message object */
					var messg:Message = Message.fromSafe(this, cast msg.data);

					/* send it to be handled */
					receiveFromPeer( messg );
				}
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
		if (is_server) {
			tab.value.sendMessage( safe );
		}

		/* Content Script */
		else {
			Runtime.sendMessage(Runtime.id, safe);
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
	  * Connect to the peer
	  */
	override public function connect(cb : Bool->Void):Void {
		if (is_server) {
			if (tab.exists) 
				cb( true );
			else
				_connected.on(function(x) cb(true));
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

	/*erver) The MessagePool [this] is attached to */
	public var pool : Null<Server>;

	/* (server) The Signal fired when [tab] is declared */
	private var _connected : Signal<Dynamic>;

/* === Static Fields === */

	public static var instance : ExtMessager;
}
