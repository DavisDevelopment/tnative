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
	  * Read the next [dis] bytes
	  */
	public function read(dis : Int):ByteArray {
		var data = new ByteArray();
		for (i in 0...dis) {
			data.push(pop());
		}
		return data;
	}

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

	/**
	  * Peek ahead the next [dis] bytes
	  */
	public function peekAhead(dis : Int):ByteArray {
		var data:ByteArray = new ByteArray();
		for (i in 1...(dis + 1)) {
			data.push(peek( i ));
		}
		return data;
	}

	/**
	  * Get a clone of [this]
	  */
	override public function copy():Stack<Byte> {
		return cast new ByteStack( this.data );
	}
}
