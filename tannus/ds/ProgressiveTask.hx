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
	    var pc = completion;
	    completion = v;
	    if (pc.value != completion.value) {
	        var delta:Delta<Percent> = new Delta(completion, pc);
	        onProgress.call( delta );
	    }
		return (completion = v);
	}

/* === Instance Fields === */

	public var onProgress : Signal<Delta<Percent>>;
}
