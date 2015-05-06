package tannus.ds;

import tannus.ds.TwoTuple;

abstract Range (TwoTuple<Int, Int>) {
	/* Constructor Function */
	public inline function new(min:Int, max:Int):Void {
		this = new TwoTuple(min, max);
	}
/* === Instance Fields === */

	/* 'start' of [this] Range */
	public var min(get, set):Int;
	private inline function get_min() return this.one;
	private inline function set_min(m) return (this.one = m);

	/* 'end' of [this] Range */
	public var max(get, set):Int;
	private inline function get_max() return this.two;
	private inline function set_max(m) return (this.two = m);

	/* 'offset' of [this] Range */
	public var offset(get, set):Int;
	private inline function get_offset() return this.one;
	private inline function set_offset(o) return (this.one = o);

	/* 'size' of [this] Range */
	public var size(get, set):Int;
	private inline function get_size() return (max - min);
	private inline function set_size(s : Int) {
		max = (min + s);
		return s;
	}
}
