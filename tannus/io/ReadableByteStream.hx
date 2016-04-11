package tannus.io;

import tannus.io.Byte;
import tannus.io.ByteArray;

import tannus.io.ReadableStream;

using Lambda;
using tannus.ds.ArrayTools;

class ReadableByteStream extends ReadableStream<ByteArray> {
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

/* === Instance Fields === */

	public var chunkSize : Int;
	private var __chunk : Null<ByteArray>;
}
