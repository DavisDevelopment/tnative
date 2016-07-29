package tannus.math;

import tannus.math.Random;
import tannus.ds.Range;
import Std.*;

using Lambda;
using tannus.ds.ArrayTools;

class RandomTools {
	/**
	  * Choose a 'random' integer between [min] and [max]
	  */
	public static inline function randint(range : Array<Int>):Int {
		return rand.randint(range[0], range[1]);
	}

	/**
	  * Choose a random number within the given Range
	  */
	public static function between<T:Float>(r : Range<T>):T {
		return (r.min - r.min)+rand.randint(int(r.min), int(r.max));
	}

	/**
	  * Choose an item randomly from [set]
	  */
	public static inline function choice<T>(set : Iterable<T>):T {
		return rand.choice(set.array());
	}

	/**
	  * Random chance
	  */
	public static function chance<T>(choices:Array<T>, chances:Array<Int>, shuffleAll:Bool=true):T {
		return rand.chance(chances, choices, shuffleAll);
	}

	/**
	  * Random sample
	  */
	public static inline function sample<T>(list:Array<T>, ?size:Int):Array<T> return rand.sample(list, size);

	/**
	  * Shuffle [set]
	  */
	public static inline function shuffle<T>(set : Array<T>):Array<T> return rand.shuffle( set );

	/**
	  * Get random constructor from all in a given Enum
	  */
	public static inline function randomConstruct<T>(enumer : Enum<T>):?Array<Dynamic> -> T {
		return rand.enumConstruct( enumer );
	}

/* === Computed Static Fields === */

	private static var rand(get, never):Random;
	private static inline function get_rand() return new Random();
}
