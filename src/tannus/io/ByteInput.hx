package tannus.io;

import tannus.io.Ptr;
import tannus.io.Byte;
import tannus.io.ByteArray;
import tannus.ds.Maybe;

import haxe.io.Input;
import haxe.io.Eof;

@:forward
abstract ByteInput (Input) from Input to Input {
	/* Constructor Function */
	public inline function new(source : Input):Void {
		this = source;
	}

/* === Instance Methods === */

	/**
	  * Read a single byte of data from [src]
	  */
	public inline function readByte():Byte {
		return (this.readByte());
	}

	/**
	  * Read [size] bytes of data
	  */
	public inline function read(size : Int):ByteArray {
		var res:ByteArray = new ByteArray();

		for (i in 0...size) {
			res.push(readByte());
		}

		return res;
	}
}
