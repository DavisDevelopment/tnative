package tannus.io;

import tannus.io.Ptr;
import tannus.io.Byte;
import tannus.io.ByteArray;
import tannus.ds.Maybe;

import haxe.io.Output;
import haxe.io.Eof;

@:forward
abstract ByteOutput (Output) from Output to Output {
	/* Constructor Function */
	public inline function new(dest : Output):Void {
		this = dest;
	}

/* === Instance Methods === */

	/**
	  * Write a single Byte of data onto [this] Output
	  */
	public inline function writeByte(b : Byte):Void {
		this.writeByte( b );
	}

	/**
	  * Write a ByteArray onto [this] Output
	  */
	public inline function write(data : ByteArray):Void {
		this.write( data );
	}

/* === Class Methods === */
}
