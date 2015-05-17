package tannus.geom;

import tannus.geom.Point;
import tannus.geom.Rectangle;

/**
  * Class to represent a Line between two points
  */
class Line {
	/* Constructor Function */
	public function new(o:Point, t:Point):Void {
		one = o;
		two = t;
	}

/* === Instance Methods === */

	/**
	  * Convert to human-readable String
	  */
	public inline function toString():String {
		return ('Line<(${start.x}, ${start.y}) => (${end.x}, ${end.y})>');
	}

/* === Computed Instance Fields === */

	/**
	  * The 'length' of [this] Line
	  */
	public var length(get, never):Float;
	private inline function get_length():Float {
		return (one.distanceFrom(two));
	}

	/**
	  * 'start', an alias for [one]
	  */
	public var start(get, set):Point;
	private inline function get_start() return one;
	private inline function set_start(ns) return (one = ns);

	/**
	  * 'end', an alias for [two]
	  */
	public var end(get, set):Point;
	private inline function get_end() return two;
	private inline function set_end(ne) return (two = ne);

	/**
	  * The smallest Rectangle which would hold [this] Line
	  */
	public var rectangle(get, never):Rectangle;
	private inline function get_rectangle():Rectangle {
		var min:Point = (one > two ? two : one);
		var max:Point = (one > two ? one : two);

		return new Rectangle(min.x, min.y, (max.x - min.x), (max.y - min.y));
	}

/* === Instance Fields === */

	public var one:Point;
	public var two:Point;
}
