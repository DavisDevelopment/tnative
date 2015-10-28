package tannus.geom;

import tannus.math.TMath.i;
import tannus.geom.Point;
import tannus.geom.Rectangle;

/**
  * abstract class to represent a Square
  */
@:forward(x, y, position, center, equals, contains, containsPoint)
abstract Square (Rectangle) {
	/* Constructor Function */
	public inline function new(?x:Float=0, ?y:Float=0, ?size:Float=0):Void {
		this = new Rectangle(x, y, size, size);
	}

/* === Instance Fields === */

	/**
	  * The size of [this] Square
	  */
	public var size(get, set):Float;
	private inline function get_size():Float {
		return (this.w);
	}
	private inline function set_size(ns : Float):Float {
		this.w = ns;
		this.h = ns;
		return size;
	}

	/**
	  * [size] as an Int
	  */
	public var isize(get, set):Int;
	private inline function get_isize() return i(size);
	private inline function set_isize(v : Int) return i(size = v);

/* === Instance Methods === */

	/**
	  * Create and return a clone of [this] Square
	  */
	public inline function clone():Square {
		return new Square(this.x, this.y, size);
	}

/* === Implicit Casting === */

	/* To Rectangle */
	@:to
	public inline function toRectangle():Rectangle {
		return cast this;
	}
}
