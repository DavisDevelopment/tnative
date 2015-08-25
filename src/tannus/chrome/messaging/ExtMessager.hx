package tannus.chrome.messaging;

import tannus.messaging.*;
import tannus.ds.Object;
import tannus.ds.Memory;
import tannus.ds.Maybe;
import tannus.io.Ptr;
import tannus.io.Signal;
import tannus.chrome.Runtime;
import tannus.chrome.Tabs;
import tannus.chrome.Tab;
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
	}

/* === Instance Methods === */

	/**
	  * Initialize [this] Messager
	  */
	private function __init():Void {
		if (is_server) {
			Runtime.onMessage(function( msg ) {
				if (SafeMessage.isSafeMessage(msg.data)) {
					if (tab == null) {
						if (inPool) {
							var existing = pool.getMessagerByTab(msg.sender.tab.value.id);
							if (existing != null)
								return ;
						}
						tab = msg.sender.tab.value;
						_connected.call(null);
					} else {
						if (msg.sender.tab.value.id != tab.value.id)
							return ;
					}

					var safe:SafeMessage = (cast msg.data);
					var messg:Message = Message.fromSafe(this, safe);
					receiveFromPeer( messg );
				} 
				else {
					trace( msg.data );
					msg.respond('No');
				}
			});

			_connected.once(function(x) {
				send('meta:source', {'tab': tab.value.id});
			});
		}
		else {
			Runtime.onMessage(function( msg ) {
				if (SafeMessage.isSafeMessage(msg.data)) {
					var messg:Message = Message.fromSafe(this, cast msg.data);
					receiveFromPeer( messg );
				}
			});

			on('meta:source', function( msg ) {
				var tabid:Int = cast msg.data['tab'];

				trace('I am in Tab $tabid');
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
}
