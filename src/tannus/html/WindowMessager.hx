package tannus.html;

import tannus.messaging.*;
import tannus.ds.Object;
import tannus.io.Signal;

import js.Browser.window in win;
import js.html.Window;
import js.html.MessageEvent in Ev;
import Std.*;

class WindowMessager extends Messager {
	/* Constructor Function */
	public function new(server:Bool=false):Void {
		super();
		is_server = server;
		peer = null;
		_connected = new Signal();

		__init();
	}

/* === Instance Methods === */

	/**
	  * Initialize [this]
	  */
	private function __init():Void {
		win.addEventListener('message', function(event : Ev) {
			var data:Object = event.data;

			trace( data );

			if (SafeMessage.isSafeMessage(data)) {
				if (peer == null) {
					peer = cast event.source;
					_connected.call( peer );
					var safe:SafeMessage = (cast data);
					var msg:Message = Message.fromSafe(this, safe);
					receiveFromPeer( msg );
				} else {
					if (event.source != peer) {
						return ;
					}
					
					var safe:SafeMessage = (cast data);
					var msg:Message = Message.fromSafe(this, safe);
					receiveFromPeer( msg );
				}
			} else {
				trace( data );
			}
		});
		
		once('meta:connect', function(msg) {
			msg.reply( true );
		});
	}

	/**
	  * Connect [this] Server Socket to a Window
	  */
	public function connectWindow(w:Window, cb:Void->Void):Void {
		var msg:Message = new Message(this, {});
		awaitingReply[msg.id] = (function(connected:Bool) {
			_connected.call( w );
			peer = w;
			cb();
		});
		msg.channel = 'meta:connect';

		w.postMessage(msg.safe(), '*');
	}

	/**
	  * Send a Message to the Peer Window
	  */
	override public function sendToPeer(msg : Message):Void {
		var safe = msg.safe();
		
		peer.postMessage(safe, '*');
	}

	/**
	  * Receive a Message from the Peer
	  */
	override public function receiveFromPeer(msg : Message):Void {
		incoming.call( msg );
		switch (msg.type) {
			case Normal:
				if (msg.channel != '') {
					var sig = chanSig(msg.channel);
					sig.call( msg );
				}

			case Reply:
				var func = awaitingReply[msg.id];
				if (func != null)
					func( msg.data );

			default:
				null;
		}
	}

/* === Instance Fields === */

	/* Whether [this] is the Server Socket */
	private var is_server : Bool;

	/* The peer Window that [this] is connected to */
	private var peer : Null<Window>;

	/* Signal to fire when we make a connection */
	private var _connected : Signal<Window>;
}
