package tannus.html.fs;

import tannus.io.Byte;
import tannus.io.ByteArray;
import tannus.io.Input;
import tannus.io.ByteArrayInput;
import tannus.io.ByteArrayOutput;
import tannus.math.TMath.*;

import tannus.html.fs.WebFile;
import tannus.html.fs.WebFile.WebFileReader;

using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;

class WebFileOutput extends ByteArrayOutput {
	/* Constructor Function */
	public function new(w : WebFileWriter):Void {
		super();

		writer = w;
	}

/* === Instance Methods === */

	/**
	  * write the data to the file
	  */
	override private function __write(data:ByteArray, done:Void->Void):Void {
		writer.seek( position );
		writer.write(data, function(error : Null<Dynamic>) {
			if (error != null) {
				throw error;
			}
			else {
				done();
			}
		});
	}

	override private function __size(?v : Int):Int {
		if (v != null) {
			writer.truncate( v );
		}
		
		return writer.length;
	}

	override private function __position(?v : Int):Int {
		if (v != null) {
			writer.seek( v );
		}
		
		return writer.position;
	}

/* === Instance Fields === */

	private var writer : WebFileWriter;
	private var offset : Int;
}
