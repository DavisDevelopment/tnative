package tannus.math;

import tannus.math.Random;

class RandomTools {
	/**
	  * Choose a 'random' integer between [min] and [max]
	  */
	public static inline function randint(range : Array<Int>):Int {
		return rand.randint(range[0], range[1]);
	}

	/**
	  * Choose an item randomly from [set]
	  */
	public static inline function choice<T>(set : Array<T>):T return rand.choice( set );

	/**
	  * Shuffle [set]
	  */
	public static inline function shuffle<T>(set : Array<T>):Array<T> return rand.shuffle( set );

/* === Computed Static Fields === */

	private static var rand(get, never):Random;
	private static inline function get_rand() return new Random();
}
