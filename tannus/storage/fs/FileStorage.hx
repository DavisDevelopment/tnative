package tannus.storage.fs;

import tannus.storage.Storage;
import tannus.ds.Object;
import tannus.ds.Delta;
import tannus.io.Signal;
import tannus.io.ByteArray;
import tannus.sys.Path;
import tannus.sys.File;

import haxe.Json;
/*
import haxe.io.Bytes;
import sys.FileSystem in Fs;
import sys.io.File;
*/

using tannus.ds.MapTools;

class FileStorage extends Storage {
	/* Constructor Function */
	public function new(path : Path):Void {
		super();

		this.path = path;
		file = new File( path );
	}

/* === Instance Methods === */

	/**
	  * Get the contents of the File
	  */
	private function getData():String {
		var res:String = '';
		try {
			res += file.read();
		}
		catch (err : Dynamic) {
			null;
		}
		return res;
	}

	/**
	  * Fetch that data, dood
	  */
	override private function _fetch(cb : Data->Void):Void {
		var str = getData();
		if (str.length == 0) {
			cb(new Map());
		}
		else {
			var data:Object = Json.parse( str );
			cb( data );
		}
	}

	/**
	  * Push that data, dood
	  */
	override private function _push(data:Data, cb:Err->Void):Void {
		var error:Err = null;
		try {
			var str:String = Json.stringify(data, null, '    ');
			file.writeString( str );
		}
		catch (err : Dynamic) {
			error = err;
		}
		cb( error );
	}

/* === Instance Fields === */

	private var path : Path;
	private var file : File;
}
