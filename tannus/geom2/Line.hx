package tannus.geom2;

import tannus.ds.DataView;

import Std.*;
import tannus.math.TMath.*;

using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;

class Line <T:Float> {
	/* Constructor Function */
	public inline function new(?a:Point<T>, ?b:Point<T>):Void {
		// initialize starting values
		if (a != null) {
			one = a;
		}
		if (b != null) {
			two = b;
		}
	}

/* === Instance Methods === */

	/**
	  * Create and return a deep copy of [this]
	  */
	public inline function clone():Line<T> {
		return new Line(one, two);
	}

	public inline function pointAlong(prog : Float):Point<Float> {
	    return a.lerp(b, prog);
	}

/* === Computed Instance Fields === */

	public var one(get, set):Point<T>;
	private inline function get_one():Point<T> return a;
	private inline function set_one(v) return (a = v);

	public var two(get, set):Point<T>;
	private inline function get_two():Point<T> return b;
	private inline function set_two(v) return (b = v);

	public var length(get, never):Float;
	private inline function get_length():Float return a.distanceFrom( b );

	public var mid(get, never):Point<Float>;
	private inline function get_mid():Point<Float> {
		return a.lerp(b, 0.5);
	}

/* === Instance Fields === */

    /*
	private var a_x : T;
	private var a_y : T;
	private var a_z : T;
	private var b_x : T;
	private var b_y : T;
	private var b_z : T;
	private var d : DataView<Point<T>>;
	*/

    public var a : Point<T>;
    public var b : Point<T>;
}
