package tannus.geom;

import tannus.math.TMath;

using tannus.math.TMath;

/**
  * abstract class to represent a geometric angle(0 - 360) degrees
  */
abstract Angle (Float) from Float to Float {
	/* Constructor Function */
	public inline function new(degs : Float):Void {
		this = degs;
	}

/* === Instance Methods === */

	/**
	  * Compliment of [this] Angle
	  */
	@:op( !A )
	public inline function compliment():Angle {
		return new Angle(360 - degrees);
	}

	/* post-increment */
	@:op( A++ )
	public inline function postincrement():Angle return new Angle(this++);
	
	/* pre-increment */
	@:op( ++A )
	public inline function preincrement():Angle return new Angle(++this);

/* === Instance Fields === */

	/* [this] Angle represented as degrees */
	public var degrees(get, set):Float;
	private inline function get_degrees():Float {
		return this;
	}
	private inline function set_degrees(v : Float):Float {
		return (this = v.clamp(0, 360));
	}

	/* [this] Angle represented as radians */
	public var radians(get, set):Float;
	private inline function get_radians():Float {
		return (this.toRadians());
	}
	private inline function set_radians(v : Float):Float {
		return (degrees = v.toDegrees());
	}

	/**
	 * Converts [this] Angle to a human-readble String
	 */
	public inline function toString():String {
		return (degrees + '\u00B0');
	}

	/**
	  * Creates a new Angle from degrees
	  */
	public static inline function fromDegrees(fl : Float):Angle {
		return new Angle(fl);
	}

	/**
	  * Creates a new Angle from radians
	  */
	public static inline function fromRadians(fl : Float):Angle {
		return new Angle(fl * (TMath.PI / 180));
	}
}
