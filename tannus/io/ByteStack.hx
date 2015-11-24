package tannus.io;

import tannus.ds.Stack;
import tannus.io.Byte;
import tannus.io.ByteArray;

class ByteStack extends Stack<Byte> {
	/* Constructor Function */
	public function new(data : ByteArray):Void {
		super(data.toArray());
	}

/* === Instance Methods === */

	/**
	  * Read until the first instance of [delimiter]
	  */
	public function readUntil(delimiter : Byte):ByteArray {
		var res:ByteArray = new ByteArray();
		while (peek() != delimiter) {
			res.push(pop());
		}
		return res;
	}
}
