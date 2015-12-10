package tannus.io;

import tannus.io.Byte;
import tannus.io.ByteArray;
import tannus.io.WritableStream;

import tannus.ds.AsyncStack;

using Lambda;
using tannus.ds.ArrayTools;
using StringTools;
using tannus.ds.StringUtils;

class OutputStream {
	/* Constructor Function */
	public function new(o : Out):Void {
		out = o;
	}

/* === Instance Methods === */

	/**
	  * Open [this] Stream
	  */
	public function open(?done : Void->Void):Void {
		out.open( done );
	}

	/**
	  * Close [this] Stream
	  */
	public function close(?done : Void->Void):Void {
		out.close( done );
	}

	/**
	  * Flush [this] Stream
	  */
	public function flush(?done : Void->Void):Void {
		out.flush( done );
	}

	/**
	  * Pause [this] Stream
	  */
	public function pause():Void {
		out.pause();
	}

	/**
	  * Resume [this] Stream
	  */
	public function resume():Void {
		out.resume();
	}

/* === Writing Methods === */

	/**
	  * Write a single Byte to [this] Stream
	  */
	public function writeByte(c : Byte):Void {
		out.write( c );
	}

	/**
	  * Write a ByteArray to [this] Stream
	  */
	public function write(s : ByteArray):Void {
		/*
		   NOTE: there must be a faster way to do this
		*/
		for (c in s) {
			writeByte( c );
		}
	}

	/**
	  * Write [len] Bytes from [s], starting at [pos]
	  */
	public function writeBytes(s:ByteArray, pos:Int, len:Int):Void {
		var data:ByteArray = s.slice(pos, (pos + len));
		write( data );
	}

	/**
	  * Write a String to [this] Stream
	  */
	public function writeString(s : String):Void {
		write(ByteArray.ofString( s ));
	}

/* === Instance Fields === */

	private var out : Out;
}

private typedef Out = WritableStream<Byte>;
