package tannus.html.fs;

import tannus.ds.Promise;
import tannus.io.ByteArray;
import tannus.io.Signal;
import tannus.io.VoidSignal;

@:forward
abstract WebFileWriter (CWebFileWriter) from CWebFileWriter {
	public inline function new(w : FileWriter) {
		this = new CWebFileWriter( w );
	}

	@:from
	public static inline function fromFileWriter(w : FileWriter):WebFileWriter {
		return new WebFileWriter( w );
	}
}

class CWebFileWriter {
	/* Constructor Function */
	public function new(writer : FileWriter):Void {
		w = writer;
		onwrite = new VoidSignal();
		w.onwrite = untyped onwrite.fire.bind();
		onerror = new Signal();
		w.onerror = untyped onerror.call.bind(_);
		trace('writer constructed');
	}

/* === Instance Methods === */

	public inline function seek(pos : Int):Void {
		w.seek( pos );
	}

	public function write(data:ByteArray, ?cb:Null<Dynamic>->Void):Void {
		if (cb == null)
			cb = (function(x) null);
		var cbed:Bool = false;
		onwrite.once(function() {
			if (!cbed) {
				cbed = true;
				cb( null );
			}
		});
		onerror.once(function(err) {
			if (!cbed) {
				cbed = true;
				cb( err );
			}
		});
		var blob = new js.html.Blob([cast data.getData()]);
		w.seek( 0 );
		w.write( blob );
	}

	public inline function truncate(len : Int):Void {
		w.truncate( len );
	}

/* === Computed Instance Fields === */

	public var length(get, never):Int;
	private inline function get_length():Int return w.length;

	public var position(get, never):Int;
	private inline function get_position():Int return w.position;

/* === Instance Fields === */

	private var w : FileWriter;

	public var onwrite : VoidSignal;
	public var onerror : Signal<Dynamic>;
}

@:forward(length, position)
abstract OldWebFileWriter (FileWriter) from FileWriter {
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
		/*
		var calledback:Bool = false;
		cb = (function(err:Null<Dynamic>):Void {
			if ( !calledback ) {
				cb( err );
				calledback = true;
			}
		});
		*/
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

	/**
	  * set the file's length to the provided integer
	  */
	public inline function truncate(len : Int):Void {
		this.truncate( len );
	}
}

typedef FileWriter = {
	var length : Int;
	var position : Int;
	var onprogress : Dynamic->Void;
	var onwritestart : Dynamic->Void;
	var onwriteend : Dynamic->Void;
	var onwrite : Dynamic->Void;
	var onerror : Dynamic->Void;
	
	function write(blob:js.html.Blob):Void;
	function seek(pos : Int):Void;
	function truncate(len : Int):Void;
};
