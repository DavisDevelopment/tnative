package tannus.ds;

import tannus.ds.tuples.Tup2;

abstract Delta<T> (Tup2<T, Null<T>>) {
	public inline function new(cur:T, ?prev:T):Void {
		this = new Tup2(cur, prev);
	}

/* === Instance Methods === */

	/**
	  * Convert to a String
	  */
	@:to
	public inline function toString():String {
		return ('Delta($previous -> $current)');
	}

/* === Instance Fields === */

	/* The current value */
	public var current(get, never):T;
	private inline function get_current():T return this._0;

	/* The previous value */
	public var previous(get, never):Null<T>;
	private inline function get_previous():Null<T> return this._1;
}
