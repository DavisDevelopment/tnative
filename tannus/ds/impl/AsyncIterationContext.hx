package tannus.ds.impl;

import tannus.io.Input;
import tannus.io.Signal;
import tannus.io.Input.Err;
import tannus.io.Signal;
import tannus.io.VoidSignal;

import tannus.ds.impl.AsyncIterToken;

/**
  * designed specifically to be subclassed, and instances passed as such
  * AsyncIterator::iterate([ AsyncIterationContext instance ])
  */
@:allow( tannus.ds.AsyncIterator )
class AsyncIterationContext<T> {
	/* Constructor Function */
	public function new():Void {
		n = 0;
	}

/* === Instance Methods === */

	/**
	  * primary body of the 'loop'
	  */
	public function run(nextValue:T, continu:Void->Void):Void {
		value = nextValue;

		__run(value, continu);
	}

	/**
	  * method meant to be overridden to contain the loop's code
	  */
	private function __run(val:T, next:Void->Void):Void {
		trace( val );
		next();
	}

	/**
	  * method called when the end of the Iterator has been reached
	  */
	public function end():Void {
		__stop();
		__end();
	}

	/**
	  * method called when the end of the Iterator has been reached
	  */
	private function __end():Void {
		null;
	}

	/**
	  * manually terminate [this] Iteration, 'break'
	  */
	public function stop():Void {
		_broken = true;
		__stop();
	}

	/**
	  * now, this '__*' method is meant to be overridden, but by the Iterator
	  * it gets attached to
	  */
	private dynamic function __stop():Void {
		null;
	}

	/**
	  * method to handle incoming 
	  */

/* === Instance Fields === */

	// the number of iterations that have been executed thus far
	public var n(default, null):Int;
	public var value(default, null):T;

	private var _broken : Bool = false;
}
