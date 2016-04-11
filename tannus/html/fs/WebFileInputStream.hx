package tannus.html.fs;

import tannus.io.Byte;
import tannus.io.ByteArray;
import tannus.io.ReadableStream;
import tannus.io.ReadableByteStream;
import tannus.math.TMath.*;

import tannus.html.fs.WebFile;
import tannus.html.fs.WebFile.WebFileReader;

using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;

class WebFileInputStream extends ReadableByteStream {
	/* Constructor Function */
	public function new(file : WebFile):Void {
		super();

		src = file;
		reader = src.createReader();

		// five hundred kilobytes
		chunkSize = Std.int((1024 * 1024) / 2);
		chunkCount = Std.int(src.size / chunkSize);
	}

/* === Instance Methods === */

	/**
	  * read a chunk from [src] and provide the caller with it
	  */
	override private function __get(provide:Null<ByteArray>->Void, reject:Err->Void):Void {
		reader.seek( offset );
		
		function gotChunk(data : ByteArray):Void {
			chunkCount--;
			offset += data.length;
			provide( data );
			if (chunkCount == 0) {
				endOfInput();
			}
		}
		
		reader.read(chunkSize, gotChunk, reject);
	}

/* === Instance Fields === */

	public var offset : Int = 0;
	public var length : Int = -1;

	private var src : WebFile;
	private var reader : WebFileReader;
	private var chunkCount : Int;
}
