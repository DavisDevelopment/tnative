package tannus.geom2;

import tannus.ds.DataView;

import Std.*;
import tannus.math.TMath.*;

using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;

class Triangle<T:Float> {
	/* Constructor Function */
	public function new(?a:Point<T>, ?b:Point<T>, ?c:Point<T>):Void {
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
		return new Triangle(one, two, three);
	}

	/**
	  * initialize the DataView
	  */
	private function initializeDataView():Void {
		var one:Point<T> = LinkedPoint.create(a_x, a_y, a_z);
		var two:Point<T> = LinkedPoint.create(b_x, b_y, b_z);
		var three:Point<T> = LinkedPoint.create(c_x, c_y, c_z);

		d.sets([one, two, three]);
	}

/* === Computed Instance Fields === */

	public var one(get, set):Point<T>;
	private function get_one():Point<T> return d[0];
	private function set_one(v : Point<T>):Point<T> {
		var p:Point<T> = a;
		p.copyFrom( v );
		return p;
	}
	
	public var two(get, set):Point<T>;
	private function get_two():Point<T> return d[1];
	private function set_two(v : Point<T>):Point<T> {
		var p:Point<T> = two;
		p.copyFrom( v );
		return p;
	}

	public var three(get, set):Point<T>;
	private function get_three():Point<T> return d[2];
	private function set_three(v : Point<T>):Point<T> {
		var p:Point<T> = three;
		p.copyFrom( v );
		return p;
	}

/* === Instance Fields === */

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
}
