package tannus.ds.impl;

import tannus.io.Input;
import tannus.io.Signal;
import tannus.io.Input.Err;
import tannus.io.Signal;
import tannus.io.VoidSignal;

import tannus.ds.impl.AsyncIterToken;

class FunctionalAsyncDataSource<T> extends AsyncIterationDataSource<T> {
	/* Constructor Function */
	public function new(sourceFunction : SourceFunction<T>):Void {
		super();

		source = sourceFunction;
	}

/* === Instance Methods === */

	/**
	  * hand control off to [source]
	  */
	override private function run():Void {
		source( this );
	}

/* === Instance Fields === */

	private var source : SourceFunction<T>;
}

typedef SourceFunction<T> = AsyncIterationDataSource<T> -> Void;
