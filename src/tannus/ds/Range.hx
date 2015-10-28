package tannus.ds;

import tannus.math.TMath in N;

class Range<T : Float> {
	/* Constructor Function */
	public inline function new(mi:T, ma:T):Void {
		min = mi;
		max = ma;
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
		return if (v < min) min
			else if (v > max) max
				else v;
	}

	/**
	  * Show as String
	  */
	public inline function toString():String {
		return 'Range($min => $max)';
	}

/* === Computed Instance Fields === */

	/* the 'size' of [this] Range */
	public var size(get, never):T;
	private inline function get_size():T return (max - min);

/* === Instance Fields === */
	public var min:T;
	public var max:T;
}
