package tannus.io;

import tannus.io.Byte;
import tannus.io.ByteArray;

import tannus.io.Input;

import Math.*;
import tannus.math.TMath.*;

using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;

class ByteArrayOutput extends AsyncOutput<ByteArray> {
	/* Constructor Function */
	public function new():Void {
		super();

		chunkSize = -1;
		__chunk = null;
	}

/* === Instance Methods === */

	/**
	  * write a chunk of data
	  */
	override public function write(data:ByteArray, ?done:Void->Void):Void {
		if ( writable ) {
			if ( paused ) {
				buffer( data );
			}
			else {
				if (done == null) {
					done = (function() null);
				}

				/* ensure that [data] is of the proper size */
				if (chunkSize != -1) {
					if (__chunk != null) {
						data = __chunk.concat( data );
						__chunk = null;
					}

					if (data.length > chunkSize) {
						data = data.slice(0, chunkSize);
						__chunk = data.slice( chunkSize );
					}
				}

				__write(data, done);
			}
		}
		else {
			error('Cannot write to closed or unopened Stream!');
		}
	}

	/**
	  * Close [this] Output
	  */
	override public function close(?done : Void->Void):Void {
		super.close( done );
		if (done == null) {
			done = (function() null);
		}
		if (__chunk != null) {
			__write(__chunk, done);
		}
		else {
			done();
		}
	}

	/**
	  * Set the length of [this] Output to [len]
	  */
	public inline function truncate(len : Int):Void {
		length = len;
	}

	/**
	  * Move to the given position
	  */
	public inline function seek(pos : Int):Int {
		return (position = pos);
	}

	/**
	  * internal method used to get/set the length of existing data
	  */
	private function __size(?value : Int):Int {
		return -1;
	}

	/**
	  * internal method used to get/set the position at which data is written
	  */
	private function __position(?value : Int):Int {
		return -1;
	}

/* === Computed Instance Fields === */

	/* the length of data already written to [this] Output */
	public var length(get, set):Int;
	private inline function get_length():Int return __size();
	private inline function set_length(v : Int):Int return __size( v );

	/* the offset at which to write new data */
	public var position(get, set):Int;
	private inline function get_position():Int return __position();
	private inline function set_position(v : Int):Int return __position( v );

/* === Instance Fields === */

	public var chunkSize : Int;
	private var __chunk : Null<ByteArray>;
}
