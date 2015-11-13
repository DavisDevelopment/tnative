package tannus.ds;

import tannus.ds.tuples.Tup2;

abstract Delta<T> (Tup2<T, Null<T>>) {
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

/* === Instance Fields === */

	/* The current value */
	public var current(get, never):Null<T>;
	private inline function get_current():Null<T> return this._0;

	/* The previous value */
	public var previous(get, never):Null<T>;
	private inline function get_previous():Null<T> return this._1;
}
