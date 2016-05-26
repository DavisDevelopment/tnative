package tannus.geom;

import tannus.geom.Point;
import tannus.geom.Rectangle;
import tannus.geom.Line;
import tannus.geom.Shape;
import tannus.geom.Vertices;

import Math.*;

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
	  * Split [this] Triangle into two triangles
	  */
	public function bisect():Array<Triangle> {
		var mp = (new Line(one, three).mid);
		var l = new Triangle(one, two, mp);
		var r = new Triangle(mp, two, three);
		return [l, r];
	}

	/**
	  * check whether the given Point is in [this] Triangle
	  */
	public function containsPoint(p : Point):Bool {
		var a = three.minusPoint( one );
		var b = two.minusPoint( one );
		var c = p.minusPoint( one );
		
		var dot_aa = dot(a, a);
		var dot_ab = dot(a, b);
		var dot_ac = dot(a, c);
		var dot_bb = dot(b, b);
		var dot_bc = dot(b, c);

		var invDenom:Float = (1 / (dot_aa * dot_bb - dot_ab * dot_ab));
		var u = (dot_bb * dot_ac - dot_ab * dot_bc) * invDenom;
		var v = (dot_aa * dot_bc - dot_ab * dot_ac) * invDenom;
		return ((u >= 0) && (v >= 0) && (u + v < 1));
	}

	private inline function dot(x:Point, y:Point):Float {
		return ((x.x * y.x) + (x.y * y.y));
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

	/**
	  * Get the vertex-list for [this] Triangle
	  */
	public function getVertices(?precision : Int):Vertices {
		return lines;
	}

/* === Computed Instance Fields === */

	/* the center of [this] Triangle */
	public var center(get, never):Point;
	private function get_center():Point {
		var cx:Float = ((one.x + two.x + three.x) / 3);
		var cy:Float = ((one.y + two.y + three.y) / 3);
		var cz:Float = ((one.z + two.z + three.z) / 3);
		return new Point(cx, cy, cz);
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

	/**
	  * The three Points that make up [this] Triangle, as an Array
	  */
	public var points(get, set):Array<Point>;
	private inline function get_points():Array<Point> return [one, two, three];
	private function set_points(v : Array<Point>):Array<Point> {
		one = v[0];
		two = v[1];
		three = v[2];
		return points;
	}
}
