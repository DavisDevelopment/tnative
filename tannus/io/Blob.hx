package tannus.io;

import tannus.io.ByteArray;
import tannus.io.Asserts.nn;
import tannus.sys.File;
import tannus.sys.Path;
import tannus.sys.Mime;
import tannus.sys.Mimes;

#if js
import tannus.html.Blobable;
import js.html.Blob in JBlob;
#end

/**
  * Abstract around Blob, which allows it to unify with multiple other types
  */
@:forward
abstract Blob (CBlob) from CBlob to CBlob {
	/* Constructor Function */
	public inline function new(name:String, ?mime:Mime, ?dat:ByteArray):Void {
		this = new CBlob(name, mime, dat);
	}

/* === Implicit Type Casting === */

	#if (js && !node)
		/**
		  * Convert to a native Blob
		  */
		@:to
		public inline function toNativeBlob():js.html.Blob {
			return (new js.html.Blob([untyped this.data.getData()], {
				'type': this.type
			}));
		}

		/**
		  * Retrieve an ObjectURL for [this] Blob
		  */
		public inline function toObjectURL():String {
			return (untyped __js__('URL.createObjectURL'))(toNativeBlob());
		}
	#end

	public static inline function fromDataURL(durl : String):Blob {
		return CBlob.fromDataURL( durl );
	}
}

/**
  * Unerlying class for Blob
  */
#if js
class CBlob implements Blobable {
#else
class CBlob {
#end
	/* Constructor Function */
	public function new(nam:String, ?mime:Mime, ?dat:ByteArray):Void {
		name = nam;
		nn(mime, type = _);
		if (type == null) {
			var np = new Path( name );
			type = Mimes.getMimeType( np.extension );
		}
		if (type == null) {
			type = 'text/plain';
		}
		data = new ByteArray();
		nn(dat, data = _);
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
		return data.toDataUrl(type);
	}

#if js
	/**
	  * Convert to Blob
	  */
	public function toBlob(cb:JBlob->Void, ?type:String):Void {
		if (type == null) {
			type = this.type;
		}
		cb(new JBlob([untyped data.getData()], {
			type: type
		}));
	}
#end

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

	public var name : String;
	public var type : Mime;
	public var data : ByteArray;
}
