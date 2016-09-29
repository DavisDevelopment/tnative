package tannus.ds.impl;

import tannus.io.Input;
import tannus.io.Signal;
import tannus.io.Input.Err;
import tannus.io.Signal;
import tannus.io.VoidSignal;

import tannus.ds.impl.AsyncIterToken;

class FunctionalAsyncIterationContext<T> extends AsyncIterationContext<T> {
	/* Constructor Function */
	public function new(options : FAICSpec<T>):Void {
		super();

		spec = options;
	}

/* === Instance Methods === */

	override private function __run(value:T, done:Void->Void):Void {
		spec.body(value, done);
	}

	override private function __end():Void {
		if (spec.footer != null) {
			spec.footer();
		}
	}

/* === Instance Fields === */

	private var spec : FAICSpec<T>;
}

typedef FAICSpec<T> = {
	body : T -> (Void -> Void) -> Void,
	?footer : Void -> Void
};
