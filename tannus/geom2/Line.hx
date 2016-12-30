package tannus.geom2;

import tannus.ds.DataView;

import Std.*;
import tannus.math.TMath.*;

using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;

class Line<T:Float> {
	/* Constructor Function */
	public function new(?a:Point<T>, ?b:Point<T>):Void {
		// initialize core data
		a_x = cast 0;
		a_y = cast 0;
		a_z = cast 0;
		b_x = cast 0;
		b_y = cast 0;
		b_z = cast 0;

		// initialize Point data
		d = new DataView( 2 );
		initializeDataView();

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

	/**
	  * initialize the DataView
	  */
	private function initializeDataView():Void {
		var one:Point<T> = LinkedPoint.create(a_x, a_y, a_z);
		var two:Point<T> = LinkedPoint.create(b_x, b_y, b_z);

		d.set(0, one);
		d.set(1, two);
	}

/* === Computed Instance Fields === */

	public var one(get, set):Point<T>;
	private inline function get_one():Point<T> return d[0];
	private function set_one(v : Point<T>):Point<T> {
		one.copyFrom( v );
		return one;
	}

	public var two(get, set):Point<T>;
	private inline function get_two():Point<T> return d[1];
	private function set_two(v : Point<T>):Point<T> {
		two.copyFrom( v );
		return two;
	}

	public var length(get, never):Float;
	private inline function get_length():Float {
		return one.distanceFrom( two );
	}

	public var mid(get, never):Point<Float>;
	private inline function get_mid():Point<Float> {
		return one.lerp(two, 0.5);
	}

/* === Instance Fields === */

	private var a_x : T;
	private var a_y : T;
	private var a_z : T;
	private var b_x : T;
	private var b_y : T;
	private var b_z : T;

	private var d : DataView<Point<T>>;
}
