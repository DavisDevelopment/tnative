package tannus.ds.dict;

import tannus.ds.tuples.Tup2 in Tuple;

abstract Pair<K, V> (Tuple<K, V>) {
	/* Constructor Function */
	public inline function new(key:K, value:V):Void {
		this = new Tuple(key, value);
	}

	public var key(get, never):K;
	private inline function get_key():K return this._0;

	public var value(get, set):V;
	private inline function get_value():V return this._1;
	private inline function set_value(v : V):V return (this._1 = v);
}
