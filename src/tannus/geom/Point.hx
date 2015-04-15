package tannus.geom;

import tannus.math.TMath;
import tannus.geom.Angle;

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
	  * Calculate the Angle that exists between two Points
	  */
	@:op(A % B)
	public function angleTo(other : Point):Angle {
		var angl:Float = TMath.angleBetween(x, y, other.x, other.y);
		return Angle.fromDegrees( angl );
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
}

private typedef TPoint = {x:Float, y:Float, z:Float};
