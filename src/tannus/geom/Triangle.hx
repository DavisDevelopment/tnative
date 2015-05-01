package tannus.geom;

import tannus.geom.Point;
import tannus.geom.Rectangle;

/**
  * Class to represent a Triangle
  */
class Triangle {
	/* Constructor Function */
	public function new(x:Point, y:Point, z:Point):Void {
		one = x;
		two = y;
		three = z;
	}

/* === Instance Fields === */

	public var one:Point;
	public var two:Point;
	public var three:Point;
}
