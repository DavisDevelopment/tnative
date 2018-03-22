package tannus.ds;

import tannus.ds.tuples.Tup2;

abstract Delta<T> (Tup2<Null<T>, Null<T>>) {
	/* Constructor Function */
	public inline function new(cur:Null<T>, ?prev:T):Void {
		this = new Tup2(cur, prev);
	}

/* === Instance Methods === */

	/**
	  * Convert to a String
	  */
	@:to
	public function toString():String {
		var res:String = 'Delta(';
		if (previous != null) {
			res += 'from $previous ';
		}
		res += 'to $current)';
		return res;
	}

	/**
	  * Convert to an Array for `switch` statements
	  */
	@:to
	public inline function toPair():Array<Null<T>> {
		return [previous, current];
	}

	/**
	  * create and return a Delta that is the "reverse" of [this] one
	  */
	public inline function reverse():Delta<T> {
	    return new Delta(previous, current);
	}

    /**
      * create and return a copy of [this]
      */
	public inline function clone():Delta<T> {
	    return new Delta(current, previous);
	}

/* === Instance Fields === */

	/* The current value */
	public var current(get, never):Maybe<T>;
	private inline function get_current():Maybe<T> return this._0;

	/* The previous value */
	public var previous(get, never):Maybe<T>;
	private inline function get_previous():Maybe<T> return this._1;
}
