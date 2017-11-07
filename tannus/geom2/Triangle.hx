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
	    /*
		// initialize core data
		a_x = cast 0;
		a_y = cast 0;
		a_z = cast 0;
		b_x = cast 0;
		b_y = cast 0;
		b_z = cast 0;
		c_x = cast 0;
		c_y = cast 0;
		c_z = cast 0;

		// initialize Point data
		d = new DataView( 3 );
		initializeDataView();
		*/

		if (a != null) {
			one = a;
		}
		if (b != null) {
			two = b;
		}
		if (c != null) {
			three = c;
		}
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

    /*
	private var d : DataView<Point<T>>;
	private var a_x : T;
	private var a_y : T;
	private var a_z : T;
	private var b_x : T;
	private var b_y : T;
	private var b_z : T;
	private var c_x : T;
	private var c_y : T;
	private var c_z : T;
	*/
}
