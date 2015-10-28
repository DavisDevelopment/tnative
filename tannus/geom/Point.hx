package tannus.geom;

import tannus.math.TMath;
import tannus.math.TMath.i;
import tannus.math.Percent;
import tannus.geom.Angle;
import tannus.ds.Maybe;
import tannus.ds.EitherType;

import Math.*;

#if python
	import python.Tuple;
	import python.Tuple.Tuple2;
#end

using tannus.math.TMath;

abstract Point (TPoint) {
	/* Constructor Function */
	public inline function new(?x:Float=0, ?y:Float=0, ?z:Float=0):Void {
		this = new TPoint(x, y, z);
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

	/**
	  * [x] as an Int
	  */
	public var ix(get, set):Int;
	private inline function get_ix() return i(x);
	private inline function set_ix(nix : Int) return i(x = nix);

	/**
	  * [y] as an Int
	  */
	public var iy(get, set):Int;
	private inline function get_iy() return i(y);
	private inline function set_iy(niy : Int) return i(y = niy);

	/**
	  * [z] as an Int
	  */
	public var iz(get, set):Int;
	private inline function get_iz() return i(z);
	private inline function set_iz(niz : Int) return i(z = niz);

	/**
	  * [this] Point's distance from (0, 0)
	  */
	public var d(get, never):Float;
	private inline function get_d():Float return (distanceFrom(new Point()));
	
/* === Instance Methods === */

	/**
	  * Calculate the distance between [this] and [other]
	  */
	public function distanceFrom(other : Point):Float {
		return Math.sqrt(Math.pow(Math.abs(x-other.x), 2) + Math.pow(Math.abs(y-other.y), 2));
	}

	/**
	  * Apply a Matrix to [this] Point
	  */
	public inline function transform(m : Matrix):Point {
		return m.transformPoint(clone());
	}

	/**
	  * Rotate [this] Point by the given Angle, around the given origin
	  */
	public function rotate(a:Angle, ?origin:Point):Point {
		if (origin == null)
			origin = new Point();
		var s:Float = sin( a.radians );
		var c:Float = cos( a.radians );
		var nx:Float = (c * (x-origin.x) - s * (y-origin.y));
		var ny:Float = (s * (x-origin.x) + c * (y-origin.y));
		return new Point(nx, ny);
	}

	/**
	  * Copy the state of [p] onto [this]
	  */
	public inline function copyFrom(p : Point):Void {
		x = p.x;
		y = p.y;
		z = p.z;
	}

	/**
	  * Calculates the 'sum' of two Points
	  */
	@:op(A + B)
	public function plus(other : Point):Point {
		return new Point((x + other.x), (y + other.y), (z + other.z));
	}

	/**
	  * Calculate the difference between two points
	  */
	@:op(A - B)
	public function minus(other : Point):Point {
		return new Point((x - other.x), (y - other.y), (z - other.z));
	}

	/**
	  * Subtract [n] from [this] Point
	  */
	@:op(A - B)
	public function minusFloat(n : Float):Point {
		return new Point(x-n, y-n, z-n);
	}

	/**
	  * Divide a Point
	  */
	@:op(A / B)
	public inline function dividePoint(p : Point) return this.dividePoint(p);

	/**
	  * Divide by a Float
	  */
	@:op(A / B)
	public inline function divideFloat(d : Float) return this.divideFloat(d);

	/* multiply by a Point */
	@:op(A * B)
	public inline function multPoint(p : Point) return this.multPoint(p);
	
	/* multiply by a Float */
	@:op(A * B)
	public inline function multFloat(n : Float) return this.multFloat(n);

	/* negate */
	@:op( -A )
	public inline function negate():Point {
		return this.multFloat( -1 );
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

	@:op(A == B)
	public inline function equals(other : Point):Bool {
		return (x == other.x && y == other.y && z == other.z);
	}

	@:op(A != B)
	public inline function nequals(other : Point):Bool {
		return !equals(other);
	}

	/**
	  * Calculate the Angle that exists between two Points
	  */
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
	  * Round off [this] Point's coordinates to Ints
	  */
	public inline function clamp():Void {
		this.x = ix;
		this.y = iy;
		this.z = iz;
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
	public static function fromFloatArray(a : Array<Float>):Point {
		var ma:Array<Maybe<Float>> = cast a;
		return new Point(ma[0].or(0), ma[1].or(0), ma[2].or(0));
	}

	/* From Array<Int> */
	@:from
	public static function fromIntArray(a : Array<Int>):Point {
		var ma:Array<Maybe<Int>> = cast a;
		return new Point(ma[0].or(0), ma[1].or(0), ma[2].or(0));
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
			return new Tuple([ix, iy]);
		}

		/* From Python Tuple<Float> */
		@:from
		public static function fromGenericFloatTuple(t : Tuple<Float>):Point {
			if (t.length == 3)
				return new Point(t[0], t[1], t[2]);
			else
				return new Point(t[0], t[1]);
		}

		/* From Python Tuple<Int> */
		@:from
		public static function fromGenericIntTuple(t : Tuple<Int>):Point {
			if (t.length == 3)
				return new Point(t[0], t[1], t[2]);
			else
				return new Point(t[0], t[1]);
		}

		/* To Tuple2<Float> */
		@:to
		public inline function toPythonTwoTupleFloat():Tuple2<Float, Float> {
			return Tuple2.make(x, y);
		}

		/* From Tuple2<Float> */
		@:from
		public static inline function fromPythonTwoTupleFloat(t : Tuple2<Float, Float>):Point {
			return fromGenericFloatTuple(cast t);
		}

		/* To Tuple2<Int> */
		@:to
		public inline function toPythonTwoTupleInt():Tuple2<Int, Int> {
			return Tuple2.make(ix, iy);
		}

		/* From Tuple2<Int> */
		@:from
		public static inline function fromPythonTwoTupleInt(t : Tuple2<Int, Int>):Point {
			return fromGenericIntTuple(cast t);
		}
	#end

	/**
	  * Shorthand function for creating a Percent
	  */
	private static inline function perc(what:Float, of:Float):Percent {
		return Percent.percent(what, of);
	}
}

/* Base Point Class */
class TPoint {
	/* Constructor Function */
	public function new(x:Float, y:Float, z:Float):Void {
		_x = x;
		_y = y;
		_z = z;
	}

/* === Instance Methods === */

	/**
	  * Divide by another Point
	  */
	public function dividePoint(d : Point):Point {
		return (new Point(x/d.x, y/d.y, (z!=0?z/d.z:0)));
	}

	/**
	  * Divide by a Float
	  */
	public function divideFloat(f : Float):Point {
		return (new Point(x/f, y/f, (z!=0?z/f:0)));
	}

	/**
	  * Multiply by another Point
	  */
	public function multPoint(p : Point):Point {
		return new Point(x*p.x, y*p.y, z*p.z);
	}

	/**
	  * Multiply by a Float
	  */
	public function multFloat(n : Float):Point {
		return (new Point(x*n, y*n, z*n));
	}

	private function get_x():Float return (_x);
	private function get_y():Float return (_y);
	private function get_z():Float return (_z);
	
	private function set_x(v:Float):Float return (_x = v);
	private function set_y(v:Float):Float return (_y = v);
	private function set_z(v:Float):Float return (_z = v);

/* === Instance Fields === */

	public var x(get, set):Float;
	public var y(get, set):Float;
	public var z(get, set):Float;

	private var _x:Float;
	private var _y:Float;
	private var _z:Float;
}
