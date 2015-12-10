package tannus.html.fs;

import tannus.ds.Promise;
import tannus.io.ByteArray;

@:forward(length, position)
abstract WebFileWriter (FileWriter) from FileWriter {
	/* Constructor Function */
	public inline function new(w : FileWriter):Void {
		this = w;
	}

/* === Instance Methods === */

	/**
	  * Move the cursor to the given position in [this] File
	  */
	public inline function seek(pos : Int):Void {
		this.seek( pos );
	}

	/**
	  * Write some data to the File
	  */
	public function write(data:ByteArray, ?cb:Null<Dynamic>->Void):Void {
		if (cb == null)
			cb = (function(x) null);
		this.onwriteend = function(event) {
			cb( null );
		};
		this.onerror = function(error) {
			cb( error );
		};
		var blob = new js.html.Blob([cast data.getData()]);
		this.write( blob );
	}

	/**
	  * Write some data at the end of [this] File
	  */
	public inline function append(data:ByteArray, cb:Null<Dynamic>->Void):Void {
		seek(this.length);
		write(data, cb);
	}
}

typedef FileWriter = {
	var length : Int;
	var onwriteend : Dynamic->Void;
	var onerror : Dynamic->Void;
	
	function write(blob:js.html.Blob):Void;
	function seek(pos : Int):Void;
};
