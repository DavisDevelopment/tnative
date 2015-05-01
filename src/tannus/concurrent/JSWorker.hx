package tannus.concurrent;

import tannus.ds.Maybe;
import tannus.io.ByteArray;
import tannus.io.Signal;
import tannus.io.Ptr;

/**
  * Base Class for HTML5 Workers
  */
class JSWorker<I, O> {
	/* Constructor Function */
	public function new():Void {
		null;
	}

/* === Instance Methods === */

	/**
	  * Method which is invoked upon receipt of new data to work with
	  */
	public function process(data:I, callb:Null<O>->Void):Void {
		#if debug
			trace( data );

			callb( null );
		#end

		null;
	}
}
