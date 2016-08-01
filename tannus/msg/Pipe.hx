package tannus.msg;

import tannus.ds.Memory in Mem;
import tannus.io.Signal;

class Pipe<T> {
	/* Constructor Function */
	public function new():Void {
		receive = new Signal();
	}

/* === Instance Methods === */

	/**
	  * send data through [this] Pipe
	  */
	public function send(data : T):Void {

	}

/* === Instance Fields === */

	public var receive : Signal<T>;
}
