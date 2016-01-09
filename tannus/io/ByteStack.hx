package tannus.io;

import tannus.ds.Stack;
import tannus.io.Byte;
import tannus.io.ByteArray;

class ByteStack extends Stack<Byte> {
	/* Constructor Function */
	public function new(data : ByteArray):Void {
		super([]);

		b = data;
		i = 0;
	}

/* === Instance Methods === */

	/**
	  * Read the next [dis] bytes
	  */
	public function read(dis : Int):ByteArray {
		var data = new ByteArray( dis );
		for (i in 0...dis) {
			data.writeByte(pop());
		}
		return data;
	}

	/**
	  * Read until the first instance of [delimiter]
	  */
	public function readUntil(delimiter : Byte):ByteArray {
		var res:ByteArray = new ByteArray( 0 );
		while (peek() != delimiter) {
			res.push(pop());
		}
		return res;
	}

	/**
	  * Peek ahead the next [dis] bytes
	  */
	public function peekAhead(dis : Int):ByteArray {
		var data:ByteArray = new ByteArray( dis );
		for (i in 1...(dis + 1)) {
			data.writeByte(peek(i));
		}
		return data;
	}

	/**
	  * Get a clone of [this]
	  */
	override public function copy():Stack<Byte> {
		var c = new ByteStack( b );
		c.i = i;
		return c;
	}

	/**
	  * Peek at the 'next' Byte in the Stack
	  */
	override public function peek(dis:Int=0):Byte {
		return b[i+dis];
	}

	/**
	  * Advance to the next byte, and return the current one
	  */
	override public function pop():Byte {
		return b[i++];
	}

	/* check whether [this] is currently finished */
	override private function get_empty():Bool {
		return (i >= b.length);
	}

	/**
	  * Set the [i] field of [this] Stack
	  */
	public function seek(pos : Int):Void {
		i = pos;
	}

/* === Instance Fields === */

	private var b : ByteArray;
	private var i : Int;
}
