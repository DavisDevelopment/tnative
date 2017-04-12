package tannus.math.random;

import tannus.math.TMath.*;

class BasicRandomNumberGenerator implements RandomNumberGenerator {
	/* Constructor Function */
	public function new(?seed : Int):Void {
		this.seed = (seed != null ? seed : floor(random() * INT_MAX));
		this.state = this.seed;
	}

/* === Instance Methods === */

	/**
	  * get the current state of [this] Rng
	  */
	public function getState():Int return state;

	/**
	  * get the next Integer in the progression of this algorithm
	  */
	public function nextInt():Int {
		return (state = cast ((1103515245.0 * state + 12345) % INT_MAX));
	}

/* === Instance Fields === */

	// the original seed
	private var seed : Int;

	// the current state
	private var state : Int;
}
