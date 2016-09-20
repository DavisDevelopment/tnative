package tannus.geom2;

import tannus.ds.DataView;

import Math.*;
import tannus.math.TMath.*;

using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;

class Point <T:Float> {
	/* Constructor Function */
	public function new(?x:T, ?y:T, ?z:T):Void {
		d = new DataView(3, untyped 0);
		if (x == null) x = untyped 0;
		if (y == null) y = untyped 0;
		if (z == null) z = untyped 0;
		d.sets([x, y, z]);
	}

/* === Instance Methods === */

	public inline function equals(other : Point<T>):Bool {
		return (x == other.x && y == other.y && z == other.z);
	}
	public inline function angleTo(other : Point<T>):tannus.geom.Angle {
		return new tannus.geom.Angle(angleBetween(x, other.x, y, other.y));
	}
	public inline function distanceFrom(other : Point<T>):Float {
		return sqrt(pow((x - other.x), 2) + pow((y - other.y), 2));
	}
	public inline function copyFrom(other : Point<T>):Void {
		x = other.x;
		y = other.y;
		z = other.z;
	}
	public inline function mutate<A:Float>(f : T -> A):Point<A> {
		return new Point(f( x ), f( y ), f( z ));
	}
	public inline function mutate2(o:Point<T>, f:T->T->T):Point<T> {
		return new Point(f(x, o.x), f(y, o.y), f(z, o.z));
	}
	public inline function plusPoint(other : Point<T>):Point<T> {
		return new Point((x + other.x), (y + other.y), (z + other.z));
	}
	public inline function minusPoint(o : Point<T>):Point<T> {
		return new Point((x - o.x), (y - o.y), (z - o.z));
	}
	public inline function clone():Point<T> {
		return new Point(x, y, z);
	}
	public inline function lerp(other:Point<T>, weight:Float):Point<Float> {
		return new Point(
			TMath.lerp(x, other.x, weight),
			TMath.lerp(y, other.y, weight),
			TMath.lerp(z, other.z, weight)
		);
	}

/* === Arithmetic Operators === */

	public inline function round():Point<Int> {
		return mutate( Math.round );
	}
	public inline function floor():Point<Int> {
		return mutate( Math.floor );
	}
	public inline function ceil():Point<Int> {
		return mutate( Math.ceil );
	}

/* === Computed Instance Fields === */

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
}
