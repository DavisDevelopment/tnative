package tannus.geom;

import tannus.geom.Point;
import tannus.geom.Rectangle;
import tannus.geom.Line;
import tannus.geom.Angle;

import tannus.math.Percent;

class Arc {
	/* Constructor Function */
	public function new(x:Float, y:Float, rad:Float, start:Angle, end:Angle, ?cc:Bool=false):Void {
		pos = new Point(x, y);
		radius = rad;
		start_angle = start;
		end_angle = end;
		clockwise = !cc;
	}

/* === Instance Methods === */

	/**
	  * Create and return a 'clone' of [this] Arc
	  */
	public inline function clone():Arc {
		return new Arc(pos.x, pos.y, radius, start_angle, end_angle, !clockwise);
	}

	/**
	  * Vectorize [this] Arc, relative to the given Rectangle
	  */
	public function vectorize(r : Rectangle):Arc {
		var c = clone();
		c.pos = pos.vectorize(r);

		var p:Percent = Percent.percent(radius, r.area);
		c.radius = (p.value);

		return c;
	}

	/**
	  * Devectorize [this] Arc, relative to the given Rectangle
	  */
	public function devectorize(r : Rectangle):Arc {
		var c = clone();

		var p:Percent = radius;
		c.pos = pos.devectorize(r);
		c.radius = p.of( r.area );

		return c;
	}

/* === Computed Instance Fields === */

	/**
	  * 'x' position of [this] Arc
	  */
	public var x(get, set):Float;
	private inline function get_x() return pos.x;
	private inline function set_x(nx) return (pos.x = nx);

	/**
	  * 'y' position of [this] Arc
	  */
	public var y(get, set):Float;
	private inline function get_y() return pos.y;
	private inline function set_y(ny) return (pos.y = ny);

/* === Instance Fields === */

	/* The Starting Position of [this] Arc */
	public var pos : Point;

	/* The Radius of [this] Arc */
	public var radius : Float;

	/* The Starting Angle of [this] Arc */
	public var start_angle : Angle;

	/* The Goal Angle of [this] Arc */
	public var end_angle : Angle;

	/* Whether [this] Arc Runs Clockwise */
	public var clockwise : Bool;
}
