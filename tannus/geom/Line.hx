package tannus.geom;

import tannus.geom.Point;
import tannus.geom.Rectangle;
import tannus.geom.Vertices;
import tannus.geom.Velocity;

import tannus.math.Percent;
import tannus.math.TMath;

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
	  * Check whether [this] Line intersects [other] Line
	  */
	public function intersects(other : Line):Bool {
		var sl:Line = new Line((end - start), (other.end - other.start));
		var s:Float = (-sl.sy * (sx - other.sx) + sl.sx * (sy - other.sy)) / (-sl.ex * sl.sy + sl.sx * sl.ey);
		var t:Float = ( sl.ex * (sy - other.sy) - sl.ey * (sx - other.sx)) / (-sl.ex * sl.sy + sl.sx * sl.ey);
		return ((s >= 0 && s <= 1) && (t >= 0 && t <= 1));
	}

	/**
	  * Convert to human-readable String
	  */
	public inline function toString():String {
		return ('Line<(${start.x}, ${start.y}) => (${end.x}, ${end.y})>');
	}

	/**
	  * Calculate a Point at a given percentage between [start] and [end]
	  */
	public function getPoint(d : Int):Point {
		var dist:Int = d;
		var vel = new Velocity(dist, (start.angleTo(end)));
		var res = vel.vector;
		res += start;
		res.clamp();
		return res;
	}

	/**
	  * do the stuff
	  */
	public inline function along(d : Float):Point {
		return start.lerp(end, d);
	}

	/**
	  * Obtain an Array of Points between [start] and [end]
	  */
	public function getVertices():Vertices {
		var pts:Array<Point> = new Array();
		start.clamp();
		end.clamp();

		for (i in 0...Math.round(length))
			pts.push(getPoint(i));

		return new Vertices( pts );
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
	  * the Angle between [start] and [end]
	  */
	public var angle(get, never):Angle;
	private inline function get_angle():Angle {
		return start.angleTo( end );
	}

	/**
	  * The smallest Rectangle which would hold [this] Line
	  */
	public var rectangle(get, never):Rectangle;
	private inline function get_rectangle():Rectangle {
		var min:Point = (one > two ? two : one);
		var max:Point = (one > two ? one : two);

		return new Rectangle(min.x, min.y, (max.x - min.x), (max.y - min.y));
	}

	/**
	  * alias for start.x
	  */
	public var sx(get, set):Float;
	private inline function get_sx():Float return start.x;
	private inline function set_sx(v : Float) return (start.x = v);
	
	/**
	  * alias for start.y
	  */
	public var sy(get, set):Float;
	private inline function get_sy():Float return start.y;
	private inline function set_sy(v : Float) return (start.y = v);

	/**
	  * alias for end.x
	  */
	public var ex(get, set):Float;
	private inline function get_ex():Float return end.x;
	private inline function set_ex(v : Float) return (end.x = v);
	
	/**
	  * alias for end.y
	  */
	public var ey(get, set):Float;
	private inline function get_ey():Float return end.y;
	private inline function set_ey(v : Float) return (end.y = v);

/* === Instance Fields === */

	public var one:Point;
	public var two:Point;
}
