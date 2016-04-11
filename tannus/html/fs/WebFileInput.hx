package tannus.html.fs;

import tannus.io.Byte;
import tannus.io.ByteArray;
import tannus.io.Input;
import tannus.io.ByteArrayInput;
import tannus.math.TMath.*;

import tannus.html.fs.WebFile;
import tannus.html.fs.WebFile.WebFileReader;

using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;

class WebFileInput extends ByteArrayInput {
	/* Constructor Function */
	public function new(file : WebFile):Void {
		super();

		src = file;
		reader = src.createReader();

		// five hundred kilobytes
		chunkSize = Std.int((1024 * 1024) / 2);
	}

/* === Instance Methods === */

	/**
	  * read a chunk from [src] and provide the caller with it
	  */
	override private function __get(provide:Null<ByteArray>->Void, reject:Err->Void):Void {
		reader.seek( offset );
		
		function gotChunk(data : ByteArray):Void {
			offset += data.length;
			provide( data );

			/* check whether the end of input has been reached */
			if (position == length) {
				endOfInput();
			}
		}
		
		reader.read(chunkSize, gotChunk, reject);
	}

	/**
	  * move to the given position
	  */
	override private function __position(?i : Int):Int {
		if (i != null) {
			offset = i;
		}
		return offset;
	}

	/**
	  * get the size of the file
	  */
	override private function __size():Int {
		return src.size;
	}

/* === Instance Fields === */

	private var offset : Int = 0;

	private var src : WebFile;
	private var reader : WebFileReader;
}
