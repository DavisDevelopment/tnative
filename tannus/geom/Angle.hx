package tannus.geom;

import tannus.math.TMath;
import Math.*;

using tannus.math.TMath;

/**
  * abstract class to represent a geometric angle(0 - 360) degrees
  */
@:forward
abstract Angle (CAngle) from CAngle to CAngle {
	/* Constructor Function */
	public inline function new(v : Float):Void {
		this = new CAngle( v );
	}

/* === Methods === */

	/* convert [this] to a String */
	@:to
	public inline function toString():String return this.toString();

	/* convert [this] to a Float */
	@:to
	public inline function toFloat():Float return this.toFloat();

	/**
	  * cast from a Float
	  */
	@:from
	public static inline function fromFloat(v : Float):Angle {
		return new Angle( v );
	}
}

class CAngle {
	/* Constructor Function */
	public function new(_v : Float):Void {
		v = _v;
		while (v < 0)
			v = (360 - abs( v ));
	}

/* === Instance Methods === */

	/**
	  * convert [this] to a String
	  */
	public function toString():String {
		return (v + '\u00B0');
	}

	/**
	  * convert [this] to a Float
	  */
	public function toFloat():Float {
		return v;
	}

/* === Computed Instance Fields === */

	/* the degrees in [this] shit */
	public var degrees(get, set):Float;
	private inline function get_degrees():Float return v;
	private inline function set_degrees(_v : Float):Float {
		return (v = _v);
	}

	/* the radians of [this] shit */
	public var radians(get, set):Float;
	private inline function get_radians():Float return (v * Math.PI / 180);
	private inline function set_radians(_v : Float):Float {
		v = (_v * (Math.PI / 180));
		return radians;
	}

	/* the x-shit of [this] Angle */
	public var x(get, never):Float;
	private inline function get_x():Float {
		return cos( radians );
	}

	/* the y-shit of [this] Angle */
	public var y(get, never):Float;
	private inline function get_y():Float {
		return sin( radians );
	}

/* === Instance Fields === */

	private var v : Float;
}
