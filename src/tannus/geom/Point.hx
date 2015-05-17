package tannus.geom;

import tannus.math.TMath;
import tannus.math.TMath.i;
import tannus.math.Percent;
import tannus.geom.Angle;

#if python
	import python.Tuple;
	import python.Tuple.Tuple2;
#end

abstract Point (TPoint) {
	/* Constructor Function */
	public inline function new(?x:Float=0, ?y:Float=0, ?z:Float=0):Void {
		this = {'x':x, 'y':y, 'z':z};
	}

/* === Instance Fields === */

	public var x(get, set):Float;
	private inline function get_x():Float {
		return this.x;
	}
	private inline function set_x(nx : Float):Float {
		return (this.x = nx);
	}

	public var y(get, set):Float;
	private inline function get_y():Float {
		return this.y;
	}
	private inline function set_y(ny : Float):Float {
		return (this.y = ny);
	}

	public var z(get, set):Float;
	private inline function get_z():Float return this.z;
	private inline function set_z(nz:Float):Float return (this.z = nz);

	public var d(get, never):Float;
	private inline function get_d():Float return (distanceFrom(new Point()));
	
/* === Instance Methods === */

	/**
	  * Calculate the distance between [this] and [other]
	  */
	@:op(A - B)
	public function distanceFrom(other : Point):Float {
		return Math.sqrt(Math.pow(Math.abs(x-other.x), 2) + Math.pow(Math.abs(y-other.y), 2));
	}

	/**
	  * Calculates the 'sum' of two Points
	  */
	@:op(A + B)
	public function plus(other : Point):Point {
		return new Point((x + other.x), (y + other.y), (z + other.z));
	}

	/**
	  * Compare two Points, based on their distance from (0, 0)
	  */
	@:op(A > B)
	public inline function greaterThan(other : Point):Bool {
		return (d > other.d);
	}

	@:op(A < B)
	public inline function lessThan(other : Point):Bool {
		return (!greaterThan(other));
	}

	/**
	  * Calculate the Angle that exists between two Points
	  */
	@:op(A % B)
	public function angleTo(other : Point):Angle {
		var angl:Float = TMath.angleBetween(x, y, other.x, other.y);
		return Angle.fromDegrees( angl );
	}

	/**
	  * Create and return a copy of [this] Point
	  */
	public inline function clone():Point {
		return new Point(x, y, z);
	}

	/**
	  * Vectorize [this] Point, based on a given Rectangle
	  */
	public inline function vectorize(r : Rectangle):Point {
		return new Point(perc(x, r.w), perc(y, r.h));
	}

	/**
	  * Devectorize [this] Point, based on a given Rectangle
	  */
	public inline function devectorize(r : Rectangle):Point {
		var px:Percent = new Percent(x), py:Percent = new Percent(y);
		return new Point(px.of(r.w), py.of(r.h));
	}

/* === Type Casting === */

	/**
	  * Casts [this] Point to a human-readable String
	  */
	@:to
	public inline function toString():String {
		return 'Point($x, $y, $z)';
	}

	/* To Array<Float> */
	@:to
	public inline function toArray():Array<Float> {
		return [x, y, z];
	}

	/* From Array<Float> */
	@:from
	public static inline function fromArray<T : Float> (a : Array<T>):Point {
		return new Point(a[0], a[1], a[2]);
	}

	#if flash
	
	/* To flash.geom.Point */
	@:to
	public inline function toFlashPoint():flash.geom.Point {
		return new flash.geom.Point(x, y);
	}

	/* From flash.geom.Point */
	@:from
	public static inline function fromFlashPoint(fp : flash.geom.Point):Point {
		return new Point(fp.x, fp.y);
	}

	#end

	#if java
	
	/* To java.awt.geom.Point2D */
	@:to
	public inline function toJavaPoint2D():java.awt.geom.Point2D {
		var jp = (new java.awt.geom.Point2D.Point2D_Double(x, y));
		return jp;
	}

	#end

	#if python
		/* To Python Tuple<Float> */
		@:to
		public inline function toGenericFloatTuple():Tuple<Float> {
			return new Tuple([x, y]);
		}

		/* To Python Tuple<Int> */
		@:to
		public inline function toGenericIntTuple():Tuple<Int> {
			return new Tuple([i(x), i(y)]);
		}
	#end

	/**
	  * Shorthand function for creating a Percent
	  */
	private static inline function perc(what:Float, of:Float):Percent {
		return Percent.percent(what, of);
	}
}

private typedef TPoint = {x:Float, y:Float, z:Float};
