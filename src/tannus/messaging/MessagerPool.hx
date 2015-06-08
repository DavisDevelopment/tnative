package tannus.messaging;

import tannus.messaging.*;
import tannus.ds.Object;
import tannus.ds.Dict;
import tannus.ds.Maybe;
import tannus.io.Ptr;
import tannus.io.Signal;

class MessagerPool {
	/* Constructor Function */
	public function new():Void {
		sockets = new Array();
		connected = new Signal();
		listeners = new Dict();
	}

/* === Instance Methods === */

	/**
	  * Create a new Messager
	  */
	private function createMessager():Messager {
		var msg = new Messager();
		sockets.push( msg );
		return msg;
	}

	/**
	  * Listen for new Connections
	  */
	private function listenToMessager(m : Messager):Void {
		m.connect(function(status:Bool) {
			if (status) {
				connected.call( m );
			}
		});

		for (p in listeners) {
			for (handler in p.value)
				m.on(p.key, handler);
		}
	}

	/**
	  * Create and listen to a new Messager
	  */
	private inline function next():Void {
		listenToMessager(createMessager());
	}

	/**
	  * Start the Pooling Loop
	  */
	public function listen():Void {
		connected.on(function(m : Messager) {
			next();
		});

		next();
	}

	/**
	  * Send out a Message to ALL Messagers in [this] Pool
	  */
	public function broadcast(chan:String, data:Object, ?onres:Object->Void):Void {
		for (sock in sockets) {
			sock.send(chan, data, onres);
		}
	}

	/**
	  * Listen for messages on a given channel on ALL Messagers
	  */
	public function on(chan:String, handler:Message->Void):Void {
		var handlers:Array<Message->Void>;
		if (listeners.exists(chan))
			handlers = listeners[chan];
		else
			handlers = listeners[chan] = new Array();
		handlers.push( handler );
		for (sock in sockets)
			sock.on(chan, handler);
	}

/* === Instance Fields === */

	/* The Array of Messagers attached to [this] Pool */
	public var sockets : Array<Messager>;

	/* Signal fired when a new Connection is made */
	public var connected : Signal<Messager>;

	/* The registry of listeners */
	private var listeners : Dict<String, Array<Message->Void>>;
}
