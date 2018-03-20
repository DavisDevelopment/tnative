package tannus.geom2;

import tannus.ds.DataView;

import Std.*;
import tannus.math.TMath.*;

using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;
using Slambda;

@:expose
class Triangle<T:Float> {
	/* Constructor Function */
	public function new(?one:Point<T>, ?two:Point<T>, ?three:Point<T>):Void {
	    if (one == null) one = new Point();
	    if (two == null) two = new Point();
	    if (three == null) three = new Point();

	    a = one;
	    b = two;
	    c = three;
	}

/* === Instance Methods === */

	/**
	  * Create and return a copy of [this] Triangle
	  */
	public function clone():Triangle<T> {
		return apply.fn(_.clone());
	}

    // create a new Triangle by applying [f] to all three points in this one
	public function apply<O:Float>(f : Point<T>->Point<O>):Triangle<O> {
	    return new Triangle(f(a), f(b), f(c));
	}

	public function round():Triangle<Int> return apply.fn(_.round());
	public function floor():Triangle<Int> return apply.fn(_.floor());
	public function ceil():Triangle<Int> return apply.fn(_.ceil());

/* === Computed Instance Fields === */

	public var one(get, set):Point<T>;
	private inline function get_one():Point<T> return a;
	private inline function set_one(v) return (a = v);
	
	public var two(get, set):Point<T>;
	private inline function get_two():Point<T> return b;
	private inline function set_two(v) return (b = v);

	public var three(get, set):Point<T>;
	private inline function get_three() return c;
	private inline function set_three(v) return (c = v);

/* === Instance Fields === */

    public var a : Point<T>;
    public var b : Point<T>;
    public var c : Point<T>;
}
