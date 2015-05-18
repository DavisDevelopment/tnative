package tannus.ds;

import tannus.math.TMath in N;

class Range<T : Float> {
	/* Constructor Function */
	public inline function new(mi:T, ma:T):Void {
		min = N.min(mi, ma);
		max = N.max(mi, ma);
	}

/* === Instance Methods === */

	/**
	  * Determine whether [v] is between [min] and [max]
	  */
	public inline function contains(v : T):Bool {
		return ((v > min) && (v < max));
	}

	/**
	  * Clamp [v] to the bounds of [this] Range
	  */
	public inline function clamp(v : T):T {
		return N.clamp(v, min, max);
	}

	/**
	  * Show as String
	  */
	public inline function toString():String {
		return 'Range($min => $max)';
	}

/* === Instance Fields === */
	public var min:T;
	public var max:T;
}
