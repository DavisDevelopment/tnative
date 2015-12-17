package tannus.math;

import tannus.math.TMath;
import tannus.math.TMath.*;
import tannus.math.Ratio;

import Math.*;

using Lambda;
using tannus.ds.ArrayTools;

@:expose('Random')
class Random {
	/* Constructor Function */
	public function new(?seed:Int):Void {
		this.state = (seed != null ? seed : Math.floor(Math.random() * TMath.INT_MAX));
	}

/* === Instance Methods === */

	/**
	  * Increment the 'seed' of [this] Random-Number-Generator, and return it's integer value
	  */
	public function nextInt():Int {
		this.state = cast ((1103515245.0 * this.state + 12345) % TMath.INT_MAX);
		return this.state;
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
		this.state = value;
	}

	/**
	  * Get a random integer between [min] and [max]
	  */
	public function randint(min:Int, max:Int):Int {
		return Math.floor(nextFloat() * (max - min + 1) + min);
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
	public function sample<T>(set : Array<T>):Array<T> {
		var sampleSize:Int = randint(0, set.length);
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

		while (copy.length != 1) {
			var el:T = choice(copy);
			copy.remove(el);
			result.push(el);
		}
		result.push(copy.pop());
		return result;
	}

	/**
	  * Choose a random construct from [_enum], and return a function to generate that construct
	  */
	public function enumConstruct<T>(_enum : Enum<T>):?Array<Dynamic> -> T {
		var name:String = choice(_enum.getConstructors());
		return Type.createEnum.bind(_enum, name, _);
	}

/* === Instance Fields === */

	private var state : Int;

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
