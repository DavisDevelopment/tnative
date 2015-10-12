package tannus.sys;

import tannus.ds.IntRange;

/* type to represent the options provided to a file read stream */
@:forward
abstract FileStreamOptions (Fso) from Fso to Fso {
	/* Constructor Function */
	public inline function new(start:Int, end:Int):Void {
		this = {
			'start': start,
			'end': end
		};
	}

/* === Instance Fields === */

	/* the 'start' field */
	public var start(get, set) : Int;
	private inline function get_start() return this.start;
	private inline function set_start(v : Int) return (this.start = v);

	/* the 'end' field */
	public var end(get, set) : Int;
	private function get_end():Int {
		return (this.end == null ? -1 : this.end);
	}
	private inline function set_end(v : Int) return (this.end = v);

/* === Instance Methods === */

	/**
	  * Get the desired read-range
	  */
	public inline function range():IntRange {
		return new IntRange(this.start, this.end);
	}

/* === Type Casting === */

	/* from Array */
	@:from
	public static inline function fromArray(a : Array<Dynamic>):FileStreamOptions {
		return new FileStreamOptions(cast a[0], cast a[1]);
	}
}

/* underlying type definition */
private typedef Fso = {
	var start : Int;
	@:optional var end : Int;
};
