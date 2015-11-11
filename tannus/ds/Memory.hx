package tannus.ds;

import tannus.io.Byte;
import tannus.math.Random;

using Lambda;

class Memory {
	public static var state:Int = 0;
	private static var used:Array<String> = {new Array();};

	/**
	  * Obtain a unique integer
	  */
	public static function uniqueIdInt():Int {
		var id = state;
		state++;
		return id;
	}

	/**
	  * Obtain a unique String
	  */
	public static function uniqueIdString(prefix:String=''):String {
		return (prefix + uniqueIdInt());
	}

	/**
	  * Obtain a random, unique identifier
	  */
	public static function allocRandomId(digits : Int):String {
		var id:String = '';
		var r:Random = new Random();

		/* generate [digits] random characters */
		for (i in 0...digits) {
			// the numerical range to generate the Byte from
			var range:Array<Int> = [0, 0];

			// randomly decide whether to generate a letter, or a number
			var letter:Bool = r.randbool();

			// if letter was chosen
			if ( letter ) {
				// randomly decide between upper and lower cases
				var upper:Bool = r.randbool();

				range = (upper ? [65, 90] : [97, 122]);
			}

			// if number was chosen
			else {
				range = [48, 57];
			}

			var c:Byte = new Byte(r.randint(range[0], range[1]));
			id += c.aschar;
		}

		/* if the generated id has already been generated */
		if (used.has( id )) {
			return allocRandomId( digits );
		}

		/* otherwise */
		else {
			used.push( id );
			return id;
		}
	}

	/**
	  * de-allocate a given id
	  */
	public static function freeRandomId(id : String):Bool {
		return used.remove( id );
	}
}
