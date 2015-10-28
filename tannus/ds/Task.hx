package tannus.ds;

import tannus.io.Signal;

class Task {
	/* Constructor Function */
	public function new():Void {
		complete = new Signal();
		_abort = new Signal();
	}

/* === Instance Methods === */

	/**
	  * Get current time-stamp
	  */
	private inline function currentTime():Int
		return Math.floor(Date.now().getTime());

	/**
	  * Run [this] Task
	  */
	@:final
	public function run():Void {
		if (!running) {
			running = true;
			action( finish );
		}
	}

	/**
	  * Actual stuff to be done
	  */
	dynamic public function action(done : Void->Void):Void {
		done();
	}

	/**
	  * Declare [this] Task 'complete'
	  */
	private function finish():Void {
		running = false;
		complete.call(currentTime());
	}

	/**
	  * Immediately stop the currently running Task
	  */
	@:final
	public function abort():Void {
		_abort.call(currentTime());
	}

/* === Instance Fields === */

	public var running : Bool = false;
	public var complete : Signal<Int>;
	private var _abort : Signal<Int>;
}
