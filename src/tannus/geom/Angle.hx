package tannus.geom;

import tannus.math.TMath;

/**
  * abstract class to represent a geometric angle(0 - 360) degrees
  */
abstract Angle (Float) from Float to Float {
	/* Constructor Function */
	public inline function new(degs : Float):Void {
		this = degs;
	}

/* === Instance Fields === */

	/* [this] Angle represented as degrees */
	public var degrees(get, never):Float;
	private inline function get_degrees():Float {
		return this;
	}

	/* [this] Angle represented as radians */
	public var radians(get, never):Float;
	private inline function get_radians():Float {
		return (this * (TMath.PI / 180));
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
