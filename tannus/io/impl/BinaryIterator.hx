package tannus.io.impl;

import tannus.io.Binary;
import tannus.io.Byte;

class BinaryIterator {
	/* Constructor Function */
	public function new(b : Binary):Void {
		bin = b;
		index = 0;
	}

/* === Instance Methods === */

	public function hasNext():Bool {
		return (index <= (bin.length - 1));
	}

	public function next():Byte {
		var c:Byte = bin.get( index );
		index++;
		return c;
	}

/* === Instance Fields === */

	private var index : Int;
	private var bin : Binary;
}
