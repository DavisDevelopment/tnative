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

/* === Computed Instance Fields === */

	/**
	  * The 'length' of [this] Line
	  */
	public var length(get, never):Float;
	private inline function get_length():Float {
		return (one.distanceFrom(two));
	}

/* === Instance Fields === */

	public var one:Point;
	public var two:Point;
}
