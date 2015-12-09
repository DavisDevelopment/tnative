package tannus.geom;

import tannus.ds.tuples.Tup4;

class Position {
	/* Constructor Function */
	public function new(top:Float=0, right:Float=0, bottom:Float=0, left:Float=0):Void {
		this.top = top;
		this.right = right;
		this.bottom = bottom;
		this.left = left;
	}

/* === Instance Methods === */

	/**
	  * Create and return a copy of [this] Position
	  */
	public inline function clone():Position {
		return new Position(top, right, bottom, left);
	}

/* === Instance Fields === */

	public var top : Float;
	public var bottom : Float;
	public var left : Float;
	public var right : Float;
}
