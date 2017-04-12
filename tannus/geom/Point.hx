package tannus.geom;

import tannus.math.TMath.*;
import tannus.math.TMath.i;
import tannus.math.Percent;
import tannus.geom.Angle;
import tannus.ds.Maybe;
import tannus.ds.EitherType;
import tannus.io.Ptr;
import tannus.io.Getter;

import haxe.macro.Expr;


#if python
	import python.Tuple;
	import python.Tuple.Tuple2;
#end

using tannus.math.TMath;
using tannus.macro.MacroTools;

@:forward
abstract Point (TPoint) from TPoint to TPoint {
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
	private inline function get_d():Float return (this.distanceFrom(new Point()));
	
/* === Instance Methods === */


	/**
	  * Apply a Matrix to [this] Point
	  */
	public inline function transform(m : Matrix):Point {
		return m.transformPoint(this.clone());
	}

	/*
	   ==============
	   ==== NOTE ====
	   ==============
	   when overloading the augmented-assignment operators (+=, -=, /=, *=, etc.)
	   the augmented-assignment method must appear BEFORE the method for it's accompanying 
	   operator in the type-definition
	*/

	/**
	  * Increment [this] Point by another
	  */
	@:op(A += B)
	public inline function moveByPoint(p : Point):Point return this.moveByPoint( p );

	/**
	  * Increment [this] Point by a Float
	  */
	@:op(A += B)
	public inline function moveByFloat(n : Float):Point return this.moveByFloat( n );
	@:op(A += B)
	public inline function moveByInt(n : Int):Point return this.moveByFloat( n );

	/**
	  * Calculates the 'sum' of two Points
	  */
	@:op(A + B)
	public inline function plusPoint(other : Point):Point return this.plusPoint( other );

	/**
	  * the sum of [this] and [n]
	  */
	@:op(A + B)
	public inline function plusFloat(n : Float):Point return this.plusFloat( n );
	@:op(A + B)
	public inline function plusInt(n : Int):Point return this.plusFloat( n );


	/**
	  * Decrement [this] by [other]
	  */
	@:op(A -= B)
	public inline function iminusPoint(p : Point):Point return this.iminusPoint(p);
	@:op(A -= B)
	public inline function iminusFloat(n : Float):Point return this.iminusFloat(n);

	/**
	  * Calculate the difference between two points
	  */
	@:op(A - B)
	public inline function minusPoint(p : Point):Point return this.minusPoint( p );

	/**
	  * Subtract [n] from [this] Point
	  */
	@:op(A - B)
	public inline function minusFloat(n : Float):Point return this.minusFloat( n );
	@:op(A - B)
	public inline function minusInt(n : Int):Point return this.minusFloat( n );

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
	public inline function negate():Point return this.negate();

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
	public inline function equals(p : Point):Bool return this.equals( p );

	@:op(A != B)
	public inline function nequals(p : Point):Bool return this.nequals(p);

	/**
	  * Vectorize [this] Point, based on a given Rectangle
	  */
	public inline function vectorize(r : Rectangle):Point {
		return new Point(perc(x, r.w), perc(y, r.h));
	}

	/**
	  * Devectorize [this] Point, based on a given Rectangle
	  */
	public function devectorize(r : Rectangle):Point {
		var px:Percent = new Percent(x), py:Percent = new Percent(y);
		return new Point(px.of(r.w), py.of(r.h));
	}

/* === Type Casting === */

	/**
	  * Casts [this] Point to a human-readable String
	  */
	@:to
	public inline function toString():String return this.toString();

	/* To Array<Float> */
	@:to
	public inline function toArray():Array<Float> return this.toArray();

	/* From Array<Float> */
	@:from
	public static inline function fromFloatArray(a : Array<Float>):Point return TPoint.fromFloatArray(a);

	/* From Array<Int> */
	@:from
	public static inline function fromIntArray(a : Array<Int>):Point return TPoint.fromFloatArray(cast a);


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

	/**
	  * Create a linked Point, explicitly
	  */
	public static inline function createLinked(x:Ptr<Float>, y:Ptr<Float>, ?z:Ptr<Float>):Point {
		return cast new LinkedPoint(x, y, z);
	}

	/**
	  * Create a linked Point, from a Ptr<Point>
	  */
	public static function createLinkedFromPointRef(p : Getter<Point>):Point {
		var x:Ptr<Float> = Ptr.create( p.v.x );
		var y:Ptr<Float> = Ptr.create( p.v.y );
		var z:Ptr<Float> = Ptr.create( p.v.z );
		return createLinked(x, y, z);
	}

	/**
	  * Create a linked Point, implicitly
	  */
	public static macro function linked(x:ExprOf<Float>, others:Array<ExprOf<Float>>):ExprOf<Point> {
		var args:Array<ExprOf<Ptr<Float>>> = ([x].concat(others)).map(function(e) return e.pointer());
		var result:ExprOf<Point> = (macro tannus.geom.Point.createLinked( $a{args} ));
		return result;
	}

	/**
	  * Create a linked Point from a pointer
	  */
	public static macro function linkedFromPointer(point : ExprOf<Point>):ExprOf<Point> {
		var ref:ExprOf<Ptr<Point>> = (macro tannus.io.Getter.create( $point ));
		return macro tannus.geom.Point.createLinkedFromPointRef( $ref );
	}
}

/* Base Point Class */
class TPoint implements tannus.ds.Comparable<TPoint> implements tannus.ds.IComparable<TPoint> {
	/* Constructor Function */
	public function new(x:Float, y:Float, z:Float):Void {
		_x = x;
		_y = y;
		_z = z;
	}

/* === Instance Methods === */

    public function compareTo(other : TPoint):Int {
        var xd = Reflect.compare(x, other.x);
        if (xd != 0)
            return xd;
        var yd = Reflect.compare(y, other.y);
        if (yd != 0)
            return yd;
        var zd = Reflect.compare(z, other.z);
        return zd;
    }

	/**
	  * Get the Angle between [this] and [other]
	  */
	public function angleTo(other : Point):Angle {
		return new Angle(TMath.angleBetween(x, y, other.x, other.y));
	}

	/**
	  * Calculate the distance between [this] and [other]
	  */
	public function distanceFrom(other : Point):Float {
		return Math.sqrt(Math.pow(Math.abs(x-other.x), 2) + Math.pow(Math.abs(y-other.y), 2));
	}

	/**
	  * Copy the state of [p] onto [this]
	  */
	public function copyFrom(p : Point):Void {
		x = p.x;
		y = p.y;
		z = p.z;
	}

	/**
	  * Calculates the sum of [this] Point and another
	  */
	public function plusPoint(other : Point):Point {
		return new Point((x + other.x), (y + other.y), (z + other.z));
	}

	/**
	  * The sum of [this] and the given Float
	  */
	public function plusFloat(n : Float):Point {
		return new Point((x + n), (y + n), (z + n));
	}

	/**
	  * increment [this] by [other]
	  */
	public function moveByPoint(other : Point):Point {
		x += other.x;
		y += other.y;
		z += other.z;
		return cast this;
	}

	/**
	  * increment [this] by [n]
	  */
	public function moveByFloat(n : Float):Point {
		x += n;
		y += n;
		z += n;
		return cast this;
	}

	/**
	  * The difference between [this] and [other]
	  */
	public function minusPoint(other : Point):Point {
		return new Point((x - other.x), (y - other.y), (z - other.z));
	}

	/**
	  * subtract [n] from [this]
	  */
	public function minusFloat(n : Float):Point {
		return new Point((x - n), (y - n), (z - n));
	}

	/**
	  * decrement [this] by [other]
	  */
	public function iminusPoint(other : Point):Point {
		moveByPoint( -other );
		return cast this;
	}

	/**
	  * decrement [this] by [n]
	  */
	public function iminusFloat(n : Float):Point {
		moveByFloat( -n );
		return cast this;
	}

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

	/**
	  * Negate [this] Point
	  */
	public function negate():Point {
		return multFloat( -1 );
	}

	/**
	  * Create and return a copy of [this] Point
	  */
	public function clone():Point {
		return new Point(x, y, z);
	}

	/**
	  * Clamp [this] Point
	  */
	public function clamp():Void {
		x = i( x );
		y = i( y );
		z = i( z );
	}

	/**
	  * A clamped version of [this] Point
	  */
	public function clamped():Point {
		return new Point(i(x), i(y), i(z));
	}

	/**
	  * Perform linear interpolation on [this] Point
	  */
	public function lerp(other:Point, weight:Float):Point {
		return new Point(
			TMath.lerp(x, other.x, weight),
			TMath.lerp(y, other.y, weight),
			TMath.lerp(z, other.z, weight)
		);
	}

	/**
	  * create and return a Point whose data is the result of mutating [this]'s data by [f]
	  */
	public function mutate(f : Float -> Float):Point {
		return new Point(f(x), f(y), f(z));
	}

	/**
	  * mutate [this] in-place
	  */
	public function imutate(f : Float->Float):Point {
		x = f( x );
		y = f( y );
		z = f( z );
		return cast this;
	}

	/**
	  * Check for equality between [this] and [other]
	  */
	public function equals(other : Point):Bool {
		return (x == other.x && y == other.y && z == other.z);
	}

	/* check for inequality between [this] and [other] */
	public function nequals(other : Point):Bool {
		return !equals( other );
	}

	/**
	  * Convert to String
	  */
	public function toString():String {
		return 'Point($x, $y, $z)';
	}

	/**
	  * Convert to Array<Float>
	  */
	public function toArray():Array<Float> {
		return [x, y, z];
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

/* === Static Methods === */

	/* from Array<Float> */
	public static function fromFloatArray(a : Array<Float>):Point {
		var ma:Array<Maybe<Float>> = cast a;
		return new Point(ma[0].or(0), ma[1].or(0), ma[2].or(0));
	}
}

/**
  * Variant of TPoint whose x, y, z fields are pointers to values elsewhere
  */
class LinkedPoint extends TPoint {
	/* Constructor Function */
	public function new(x:Ptr<Float>, y:Ptr<Float>, ?z:Ptr<Float>):Void {
		super(0, 0, 0);

		rx = x;
		ry = y;
		rz = (z != null ? z : Ptr.create(_z));
	}

	override private function get_x():Float return (rx._);
	override private function get_y():Float return (ry._);
	override private function get_z():Float return (rz._);
	
	override private function set_x(v:Float):Float return (rx._ = v);
	override private function set_y(v:Float):Float return (ry._ = v);
	override private function set_z(v:Float):Float return (rz._ = v);

	private var rx : Ptr<Float>;
	private var ry : Ptr<Float>;
	private var rz : Ptr<Float>;
}
