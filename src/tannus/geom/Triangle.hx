package tannus.geom;

import tannus.geom.Point;
import tannus.geom.Rectangle;
import tannus.geom.Line;

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

/* === Instance Methods === */

	/**
	  * Create and return a clone of [this] Triangle
	  */
	public inline function clone():Triangle {
		return new Triangle(one.clone(), two.clone(), three.clone());
	}

	/**
	  * Vectorize [this] Triangle
	  */
	public inline function vectorize(r : Rectangle):Void {
		one = one.vectorize(r);
		two = two.vectorize(r);
		three = three.vectorize(r);
	}

/* === Instance Fields === */

	public var one:Point;
	public var two:Point;
	public var three:Point;

/* === Computed Instance Fields === */

	/**
	  * The lines which make up [this] Triangle
	  */
	public var lines(get, never):Array<Line>;
	private function get_lines():Array<Line> {
		var la:Array<Line> = new Array();

		la.push(new Line(one, two));
		la.push(new Line(two, three));
		la.push(new Line(three, one));

		return la;
	}
}
