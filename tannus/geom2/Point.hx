package tannus.geom2;

import tannus.ds.*;

//import Math.*;
import tannus.math.TMath.*;
import tannus.ds.SortingTools.compresolve;

import haxe.Serializer;
import haxe.Unserializer;

import haxe.macro.Expr;

using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;
using haxe.macro.ExprTools;
using tannus.macro.MacroTools;

@:expose
class Point <T:Float> implements IMultiPoint<T> implements IComparable<Point<T>> {
	/* Constructor Function */
	public function new(?x:T, ?y:T, ?z:T):Void {
	    #if !js
		d = new DataView(3, untyped 0);
		if (x == null) x = untyped 0;
		if (y == null) y = untyped 0;
		if (z == null) z = untyped 0;
		d.sets([x, y, z]);

	    #else

		if (x == null)
		    x = untyped 0;

		if (y == null) 
		    y = untyped 0;

		if (z == null) 
		    z = untyped 0;

		this.x = x;
		this.y = y;
		this.z = z;

	    #end
	}

/* === Instance Methods === */

    /**
      * test if [this] is exactly equal to [other]
      */
	public inline function equals(other : Point<T>):Bool {
		return (x == other.x && y == other.y && z == other.z);
	}

	/**
	  * get the angle between [this] and [other]
	  */
	public inline function angleTo(other : Point<T>):Angle {
		return new Angle(angleBetween(x, other.x, y, other.y));
	}

	public inline function distanceFrom(other : Point<T>):Float {
		return Math.sqrt(Math.pow((x - other.x), 2) + Math.pow((y - other.y), 2));
	}

	public function dimensionality():Int {
	    return 2;
	}

	public function getCoordinate(i: Int):T {
	    return switch ( i ) {
            case 0: x;
            case 1: y;
            case 2: z;
            default: throw 'Error: OutOfBounds';
	    }
	}

	public function getRawData():Array<T> return [x, y, z];

	public function distanceFromIMultiPoint(other: IMultiPoint<T>):Float {
	    return sqrt(pow(x - other.getCoordinate(0), 2) + pow(y - other.getCoordinate(1), 2));
	}

	public function compareTo(other: Point<T>):Int {
	    return compresolve([
	        Reflect.compare(x, other.x),
	        Reflect.compare(y, other.y),
	        Reflect.compare(z, other.z)
	    ]);
	}

	/**
	  * copy over [other]'s state onto [this]
	  */
	public inline function copyFrom(other : Point<T>):Void {
	    set(other.x, other.y, other.z);
	}

	public inline function pull(other: Point<T>):Void copyFrom( other );
	
	/**
	  * create a mutation of [this] by applying [f] to x, y, and z
	  */
	public function mutate<A:Float>(f : T -> A):Point<A> {
		return new Point(f( x ), f( y ), f( z ));
	}

    /**
      * 
      */
	public function mutate2(o:Point<T>, f:T->T->T):Point<T> {
		return new Point(f(x, o.x), f(y, o.y), f(z, o.z));
	}

    /**
      * get the sum of [this] and [other]
      */
	public inline function plusPoint(other : Point<T>):Point<T> {
		return new Point((x + other.x), (y + other.y), (z + other.z));
	}

	/**
	  * subtract [o] from [this]
	  */
	public inline function minusPoint(o : Point<T>):Point<T> {
		return new Point((x - o.x), (y - o.y), (z - o.z));
	}

	/**
	  * create and return a clone of [this]
	  */
	public inline function clone():Point<T> {
		return new Point(x, y, z);
	}

	/**
	  * get some point between [this] and [other], using linear interpolation
	  */
	public inline function lerp(other:Point<T>, weight:Float):Point<Float> {
		return new Point(
			TMath.lerp(x, other.x, weight),
			TMath.lerp(y, other.y, weight),
			TMath.lerp(z, other.z, weight)
		);
	}

	/**
	  * 'set' [this]'s state
	  */
	public inline function set(nx:T, ny:T, nz:T):Void {
	    x = nx;
	    y = ny;
	    z = nz;
	}

	/**
	  * check if [this] Point is inside of [rect]
	  */
	public inline function containedBy(ox:T, oy:T, ow:T, oh:T):Bool {
        return (
            (x > ox && (x < (ox + ow))) &&
            (y > oy && (y < (oy + oh)))
        );
	}
	public inline function containedByRect(rect: Rect<T>):Bool return containedBy(rect.x, rect.y, rect.width, rect.height);

/* === Arithmetic Operators === */

    /**
      * get [this] with its values rounded
      */
	public inline function round():Point<Int> {
		return trans(_.round());
	}

	/**
	  * get [this] with its values 'floor'd
	  */
	public inline function floor():Point<Int> {
	    return trans(_.floor());
	}

	/**
	  * get [this] with its values 'ceil'd
	  */
	public inline function ceil():Point<Int> {
		//return new Point(x.ceil(), y.ceil(), z.ceil());
		return trans(_.ceil());
	}

	public inline function int():Point<Int> {
		//return new Point(x.int(), y.int(), z.int());
		return trans(_.int());
	}

	public inline function float():Point<Float> {
		//return new Point(x.float(), y.float(), z.float());
		return trans(_.float());
	}

    /**
      * encode [this] for structured cloning
      */
    @:keep
	public function hxscGetData():Array<T> {
	    return [x, y, z];
	}

    /**
      * decode [this] from structured cloning
      */
	@:keep
	public function hxscSetData(data : Array<T>):Void {
	    x = data[0];
	    y = data[1];
	    z = data[2];
	}

    /**
      * serialize [this] Point
      */
	@:keep
	public function hxSerialize(s: Serializer):Void {
	    inline function w(x: Dynamic):Void s.serialize( x );

	    w( x );
	    w( y );
	    w( z );
	}

    /**
      * unserialize [this]
      */
	@:keep
	public function hxUnserialize(u: Unserializer):Void {
	    inline function v():Dynamic return u.unserialize();

        set(v(), v(), v());
	}

	/**
	  * apply a macro transformation to [this]
	  */
	public macro function trans<Out:Float>(self:ExprOf<Point<T>>, varArgs:Array<Expr>):ExprOf<Point<Out>> {
	    var tx:Expr = macro $self.x;
	    var ty:Expr = macro $self.y;
	    var tz:Expr = macro $self.z;

	    switch ( varArgs ) {
	        // one transformation for all values
            case [et]:
                tx = et.replace(macro _, tx);
                ty = et.replace(macro _, ty);
                tz = et.replace(macro _, tz);

            case [etx, ety, etz]:
                tx = etx.replace(macro _, tx);
                ty = ety.replace(macro _, ty);
                tz = etz.replace(macro _, tz);

            default:
                throw 'Error: Invalid varargs for tannus.geom2.Point.trans';
	    }

	    return macro new tannus.geom2.Point($tx, $ty, $tz);
	}

/* === Computed Instance Fields === */

#if !js
	public var x(get, set):T;
	private inline function get_x():T return d[0];
	private inline function set_x(v : T):T return (d[0] = v);
	
	public var y(get, set):T;
	private inline function get_y():T return d[1];
	private inline function set_y(v : T):T return (d[1] = v);
	
	public var z(get, set):T;
	private inline function get_z():T return d[1];
	private inline function set_z(v : T):T return (d[1] = v);

/* === Instance Fields === */

	private var d : DataView<T>;
#else
    public var x : T;
    public var y : T;
    public var z : T;
#end
}
