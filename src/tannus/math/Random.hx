package tannus.math;

import tannus.math.TMath;

class Random {
	private var state:Int;

	public function new(?seed:Int):Void {
		this.state = (seed != null ? seed : Math.floor(Math.random() * TMath.INT_MAX));
	}
	public function nextInt():Int {
		this.state = cast ((1103515245.0 * this.state + 12345) % TMath.INT_MAX);
		return this.state;
	}
	public function nextFloat():Float {
		return (nextInt() / TMath.INT_MAX);
	}
	public function reset(value : Int):Void {
		this.state = value;
	}
	public function randint(min:Int, max:Int):Int {
		return Math.floor(nextFloat() * (max - min + 1) + min);
	}
	public function randbool():Bool {
		return (randint(0, 1) == 1);
	}
	public function choice <T> (set:Array<T>):T {
		return set[(randint(0, set.length - 1))];
	}
	public function shuffle <T> (set:Array<T>):Array<T> {
		var copy:Array<T> = set.copy();
		var result:Array<T> = new Array();

		while (copy.length != 1) {
			var el:T = choice(copy);
			copy.remove(el);
			result.push(el);
		}
		return result;
	}

	public static function stringSeed(seed : String):Random {
		var state:Int = 0;
		var ba = tannus.io.ByteArray.fromString(seed);
		for (bit in ba) {
			seed += bit.toInt();
		}
		return new Random(state);
	}
}
