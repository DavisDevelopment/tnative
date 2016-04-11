package tannus.ds;

import tannus.math.Percent;
import tannus.io.Signal;

class ProgressiveTask extends Task {
	/* Constructor Function */
	public function new():Void {
		super();

		onProgress = new Signal();
		completion = 0;
	}

/* === Instance Methods === */

	/**
	  * increase [completion] by [amount]
	  */
	public inline function progress(amount : Percent):Void {
		completion = (completion.value + amount.value);
	}

/* === Computed Instance Fields === */

	public var completion(default, set): Percent;
	private function set_completion(v : Percent):Percent {
		onProgress.call( v );
		return (completion = v);
	}

/* === Instance Fields === */

	public var onProgress : Signal<Percent>;
}
