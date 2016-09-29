package tannus.ds;

import tannus.io.Input;
import tannus.io.Signal;
import tannus.io.Input.Err;
import tannus.io.Signal;
import tannus.io.VoidSignal;

import tannus.ds.AsyncIterator;

class FunctionalAsyncIterator<T> extends AsyncIterator<T> {
	/* Constructor Function */
	public function new(func : AsyncIterationDef<T>->Void):Void {
		super();

		f = func;
	}

/* === Instance Methods === */

	override private function __iteration(d : AsyncIterationDef<T>):Void {
		f( d );
	}

/* === Instance Fields === */

	private var f : AsyncIterationDef<T> -> Void;
}
