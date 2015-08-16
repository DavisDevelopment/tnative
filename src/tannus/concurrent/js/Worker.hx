package tannus.concurrent.js;

import tannus.io.Signal;
import tannus.ds.Object;
import tannus.concurrent.IWorker;

class Worker implements IWorker {
	/* Constructor Function */
	public function new(wm : Dynamic):Void {
		wmain = wm;
		_msg = new Signal();
		_msg.on( process );
	}

/* === Instance Methods === */

	/**
	  * Listen for incoming data
	  */
	public function onMessage(cb : Object->Void):Void {
		_msg.on( cb );
	}

	/**
	  * Process some data
	  */
	public function process(data : Object):Void {
		//trace( data );
	}

	/**
	  * Send some data
	  */
	public function send(data : Object):Void {
		wmain.send( data );
	}

/* === Instance Fields === */

	private var wmain : Dynamic;
	private var _msg : Signal<Object>;
}
