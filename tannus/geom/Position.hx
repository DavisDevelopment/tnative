package tannus.geom;

import tannus.ds.tuples.Tup4;

abstract Position (Pos) {
	/* Constructor Function */
	public inline function new(top:Float, right:Float, bottom:Float, left:Float):Void {
		this = new Tup4(top, right, bottom, left);
	}

/* === Instance Methods === */

	/* clone [this] Position */
	public inline function clone():Position {
		return (untyped this.copy());
	}

/* === Instance Fields === */

	public var top(get, set):Float;
	private inline function get_top() return (this._0);
	private inline function set_top(v : Float) return (this._0 = v);

	public var right(get, set):Float;
	private inline function get_right() return (this._1);
	private inline function set_right(v : Float) return (this._1 = v);
	
	public var bottom(get, set):Float;
	private inline function get_bottom() return (this._2);
	private inline function set_bottom(v : Float) return (this._2 = v);
	
	public var left(get, set):Float;
	private inline function get_left() return (this._3);
	private inline function set_left(v : Float) return (this._3 = v);
}

private typedef Pos = Tup4<Float, Float, Float, Float>;
