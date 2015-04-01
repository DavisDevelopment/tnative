package tnative.math;

import Math;

/**
  * Class of utility functions for mathematical operations
  */
class Nums {
/* === Generic (Not Necessarily Dealing with Numbers) Methods === */

	/**
	  * Selects the larger of the two given values
	  */
	public static inline function max <T : Float> (x:T, y:T):T {
		return ((x > y) ? x : y);
	}

	/**
	  * Selects the smaller of the two given values
	  */
	public static inline function min <T : Float> (x:T, y:T):T {
		return ((x < y) ? x : y);
	}


/* === Numeric Methods === */

	/**
	  * "clamps" [value] to the range ([x] ... [y])
	  */
	public static inline function clamp <T : Float> (value:T, x:T, y:T):T {
		var result:T = value;

		result = min(value, y);
		result = max(value, x);

		return result;
	}
}
