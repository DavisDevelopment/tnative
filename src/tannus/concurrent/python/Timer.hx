package tannus.concurrent.python;

@:pythonImport('threading', 'Timer')
extern class Timr {
	function new(delay:Float, func:Dynamic):Void;
	function start():Void;
	function cancel():Void;
}

class Timer {
	public function new(intv:Float, ?f:Void->Void):Void {
		interval = intv;
		func = f;
		stopped = false;
	}

/* === Instance Methods === */

	/**
	  * Start [this] Timer
	  */
	public function start():Void {
		function tick() {
			func();

			if (!stopped) {
				var t = new Timr(interval, tick);
				t.start();
			}
		}
		tick();
	}

	/**
	  * Stop [this] Timer
	  */
	public function stop():Void {
		stopped = true;
	}

/* === Instance Fields === */
	public var interval:Float;
	public var func:Void->Void;
	private var stopped:Bool;
}
