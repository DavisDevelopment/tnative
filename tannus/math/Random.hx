package tannus.math;

import tannus.math.random.*;
import tannus.math.TMath.*;
import tannus.geom.*;
import tannus.utils.Error;

import Math.*;

using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;

@:expose('Random')
class Random {
	/* Constructor Function */
	public function new(?seed:Int):Void {
		//this.state = (seed != null ? seed : Math.floor(Math.random() * TMath.INT_MAX));
		rng = createRandomNumberGenerator( seed );
	}

/* === Instance Methods === */

	/**
	  * method used to create the RandomNumberGenerator (to change the class used as the Generator, override this method)
	  */
	private function createRandomNumberGenerator(?seed : Int):RandomNumberGenerator {
		return new BasicRandomNumberGenerator( seed );
	}

	/**
	 * Increment the 'seed' of [this] Random-Number-Generator, and return it's integer value
	 */
	public function nextInt():Int {
		return rng.nextInt();
	}

	/**
	 * Increment [this]'s seed, and return it's float value
	 */
	public function nextFloat():Float {
		return (nextInt() / TMath.INT_MAX);
	}

	/**
	 * Set the seed to [value]
	 */
	public function reset(value : Int):Void {
		null;
	}

	/**
	 * Get a random integer between [min] and [max]
	 */
	public function randint(min:Int, max:Int):Int {
		return Math.floor(nextFloat() * (max - min + 1) + min);
	}

	/**
	  * get a random value from the given Map
	  */
	public function chance<T>(chances:Array<Int>, choices:Array<T>, shuffleAll:Bool=true):T {
		if (chances.sum() != 100) {
			throw new Error('RandomError: The [chances] parameter for tannus.math.Random::chance must add up to 100');
		}
		else if (chances.length != choices.length) {
			throw new Error('RandomError: The [chances] and [choices] parameters for tannus.math.Random::chance must be of the same length');
		}
		else {
			var all:Array<T> = new Array();

			/* build the [all] array */
			for (index in 0...chances.length) {
				var count:Int = chances[ index ];
				var value:T = choices[ index ];
				
				/* add [value] to [all] [count] times */
				for (i in 0...count) all.push( value );
			}

			if ( shuffleAll ) {
				// shuffle [all]
				all = shuffle( all );
			}

			return choice( all );
		}
	}

	/**
	 * get random boolean value where [prob] is the probability that the value will be 'true'
	 */
	public function randchance(top:Int, bottom:Int):Bool {
		var choices:Array<Int> = [for (i in 0...bottom) i];
		var correct:Array<Int> = new Array();
		while (correct.length < top) {
			var cnum:Int = choice( choices );
			if (!correct.has( cnum )) {
				correct.push( cnum );
			}
		}
		return (correct.has(randint(top, bottom)));
	}

	/**
	 * Choose randomly between 'true' and 'false'
	 */
	public function randbool():Bool {
		return (randint(0, 1) == 1);
	}

	/**
	 * Choose an item from [set] at random
	 */
	public function choice<T>(set : Array<T>):T {
		return set[(randint(0, set.length - 1))];
	}

	/**
	 * choose a random number of items from [set]
	 */
	public function sample<T>(set:Array<T>, ?size:Int):Array<T> {
		var sampleSize:Int = (size == null ? randint(0, set.length) : size);
		var items:Array<T> = new Array();
		while (items.length < sampleSize) {
			var ritem:T = choice( set );
			if (!items.has( ritem ))
				items.push( ritem );
		}
		return items;
	}

	/**
	 * "shuffle" [set] by randomly re-assigning the indices of each item
	 */
	public function shuffle <T> (set:Array<T>):Array<T> {
		var copy:Array<T> = set.copy();
		var result:Array<T> = new Array();

		if (copy.length > 0) {
			while (copy.length != 1) {
				var el:T = choice(copy);
				copy.remove(el);
				result.push(el);
			}
			result.push(copy.pop());
		}

		return result;
	}

	/**
	 * Choose a random construct from [_enum], and return a function to generate that construct
	 */
	public function enumConstruct<T>(_enum : Enum<T>):?Array<Dynamic> -> T {
		var name:String = choice(_enum.getConstructors());
		return Type.createEnum.bind(_enum, name, _);
	}

	/**
	  * Choose a random Point inside the given Rectangle
	  */
	public inline function pointInRect(rect : Rectangle):Point {
		return new Point(
			randint(floor(rect.x), floor(rect.x + rect.w)),
			randint(floor(rect.y), floor(rect.y + rect.h))
		);
	}

/* === Instance Fields === */

	//private var state : Int;
	private var rng : RandomNumberGenerator;

/* === Static Methods === */

	/**
	 * Get a random-seed from a String
	 */
	public static function stringSeed(seed : String):Random {
		var state:Int = 0;
		var ba = tannus.io.ByteArray.ofString( seed );
		for (bit in ba) {
			seed += bit.asint;
		}
		return new Random(state);
	}
}
