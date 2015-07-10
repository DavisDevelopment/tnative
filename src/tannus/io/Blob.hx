package tannus.io;

import tannus.io.ByteArray;
import tannus.sys.File;
import tannus.ds.Maybe;

/**
  * Abstract around Blob, which allows it to unify with multiple other types
  */
@:forward
abstract Blob (CBlob) from CBlob to CBlob {
	/* Constructor Function */
	public inline function new(name:String, ?mime:Maybe<String>, ?dat:Maybe<ByteArray>):Void {
		this = new CBlob(name, mime, dat);
	}

/* === Implicit Type Casting === */

	public static inline function fromDataURL(durl : String):Blob {
		return CBlob.fromDataURL(durl);
	}
}

/**
  * Unerlying class for Blob
  */
class CBlob {
	/* Constructor Function */
	public function new(nam:String, ?mime:Maybe<String>, ?dat:Maybe<ByteArray>):Void {
		name = nam;
		type = mime || 'text/plain';
		data = dat || new ByteArray();
	}

/* === Instance Methods === */

	/**
	  * Save [this] Blob as a File, at the given directory
	  */
	public function save(dirname : String):File {
		var f = new File('$dirname/$name');
		f.write( data );
		return f;
	}

	/**
	  * Retrieve the DataURL of [this] Blob
	  */
	public function toDataURL():String {
		return data.toDataURI(type);
	}

/* === Static Methods === */

	/**
	  * Create a Blob from a DataURI
	  */
	public static function fromDataURL(durl : String):Blob {
		durl = durl.substring(5);
		var bits = durl.split(';');
		var mime = bits.shift();
		var encoded = durl.substring(durl.indexOf(',')+1, durl.length-1);
		var data:ByteArray = ByteArray.fromBase64(encoded);

		return new Blob('file', mime, data);
	}

/* === Instance Fields === */

	public var name:String;
	public var type:String;
	public var data:ByteArray;
}
