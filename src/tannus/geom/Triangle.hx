package tannus.geom;

import tannus.geom.Point;
import tannus.geom.Rectangle;
import tannus.geom.Line;
import tannus.geom.Shape;
import tannus.geom.Vertices;

/**
  * Class to represent a Triangle
  */
class Triangle implements Shape {
	/* Constructor Function */
	public function new(?x:Point, ?y:Point, ?z:Point):Void {
		one = (x!=null?x:new Point());
		two = (y!=null?y:new Point());
		three = (z!=null?z:new Point());
	}

/* === Instance Methods === */

	/**
	  * Create and return a clone of [this] Triangle
	  */
	public inline function clone():Triangle {
		return new Triangle(one.clone(), two.clone(), three.clone());
	}

	/**
	  * Create and return a vectorized 'clone' of [this]
	  */
	public function vectorize(r : Rectangle):Triangle {
		var c:Triangle = clone();
		c.one = one.vectorize(r);
		c.two = two.vectorize(r);
		c.three = three.vectorize(r);

		return c;
	}

	/**
	  * Devectorize [this] Triangle
	  */
	public function devectorize(r : Rectangle):Triangle {
		var c:Triangle = clone();

		c.one = one.devectorize(r);
		c.two = two.devectorize(r);
		c.three = three.devectorize(r);

		return c;
	}

	public function getVertices():Vertices {
		return lines;
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
