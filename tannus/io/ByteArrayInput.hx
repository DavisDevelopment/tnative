package tannus.io;

import tannus.io.Byte;
import tannus.io.ByteArray;

import tannus.io.AsyncInput;

using Lambda;
using tannus.ds.ArrayTools;

class ByteArrayInput extends AsyncInput<ByteArray> {
	/* Constructor Function */
	public function new():Void {
		super();

		chunkSize = -1;
		__chunk = null;
	}

/* === Instance Methods === */

	/**
	  * Read a Chunk of data
	  */
	override public function read(provide:ByteArray -> Void, ?reject:Err -> Void):Void {
		super.read(function(d : ByteArray) {
			if (!(eoi && __b.empty()) && chunkSize != -1 && d.length != chunkSize) {
				if (__chunk == null) {
					if (d.length > chunkSize) {
						__chunk = d.slice(0, chunkSize);
						d = d.slice( chunkSize );
						buffer( d );
						// provide the chunk
						provide( __chunk );
						__chunk = null;
					}
					else if (d.length < chunkSize) {
						__chunk = d;
					}
				}
				else {
					if ((__chunk.length + d.length) >= chunkSize) {
						__chunk = __chunk.concat( d );
						// provide the chunk
						provide(__chunk.slice(0, chunkSize));
						if (__chunk.length == chunkSize) {
							__chunk = null;
						}
						else {
							__chunk = __chunk.slice( chunkSize );
						}
					}
					else {
						__chunk = __chunk.concat( d );
					}
				}
			}
			else {
				// provide the chunk
				provide( d );
			}
		}, reject);
	}

	/**
	  * Move to the given offset
	  */
	public function seek(offset:Int, ?done:Void->Void):Void {
		if (done == null) {
			done = (function() null);
		}

		__seek(offset, done);
	}

	/**
	  * internal method to move to the given offset
	  */
	private function __seek(offset:Int, done:Void->Void):Void {
		__position( offset );
		done();
	}

	/**
	  * forward all data on [this] Input to the given Output
	  */
	override public function pipe(o : AsyncOutput<ByteArray>):Void {
		if (Std.is(o, ByteArrayOutput)) {
			var bo:ByteArrayOutput = cast o;
			bo.seek( position );
			bo.truncate( length );
		}

		super.pipe( o );
	}

	/**
	  * get the number of available chunks
	  */
	private function __size():Int {
		return -1;
	}

	private function __position(?v : Int):Int {
		return -1;
	}

/* === Computed Instance Fields === */

	/* the number of available chunks */
	public var length(get, never):Int;
	private inline function get_length():Int return __size();

	public var position(get, set):Int;
	private inline function get_position():Int return __position();
	private inline function set_position(v : Int):Int return __position( v );

/* === Instance Fields === */

	public var chunkSize : Int;
	private var __chunk : Null<ByteArray>;
}
