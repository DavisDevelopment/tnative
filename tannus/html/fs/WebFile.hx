package tannus.html.fs;

import tannus.html.fs.WebFileEntry;

import js.html.File in NFile;
import js.html.FileReader;
import js.html.Blob;

import tannus.ds.Promise;
import tannus.io.ByteArray;
import tannus.html.Win;
import tannus.sys.Mime;

class WebFile {
	/* Constructor Function */
	public function new(f : NFile):Void {
		file = f;
		file.lastModified;
	}

/* === Instance Methods === */

	/**
	  * Get a subset of [this] File, as a Blob
	  */
	public function slice(start:Int, ?end:Int, ?contentType:Mime):Blob {
		return file.slice(start, end, contentType);
	}

	/**
	  * Read some data from [this] File
	  */
	public function read(pos:Int=0, ?len:Int):Promise<ByteArray> {
		return cast Promise.create({
			if (len == null)
				len = size;
			var reader:FileReader = new FileReader();
			reader.onerror = function(error : Dynamic):Void {
				throw error;
			};
			reader.onload = function(event) {
				var data:ByteArray = ByteArray.ofData(cast event.target.result);
				return data;
			};

			if (pos == 0 && len == size) {
				reader.readAsArrayBuffer(cast file);
			}
			else {
				reader.readAsArrayBuffer(slice(pos, (pos+len), type));
			}
		});
	}

	/**
	  * get an 'Object URL' for [this] File
	  */
	public inline function getObjectURL():String {
		untyped {
			return Win.current.webkitURL.createObjectURL(file);
		};
	}

/* === Computed Instance Fields === */

	/* the name of [this] File */
	public var name(get, never):String;
	private inline function get_name():String return file.name;

	/* the size of [this] File in bytes */
	public var size(get, never):Int;
	private inline function get_size():Int return file.size;

	/* the MIME type of [this] File */
	public var type(get, never):Mime;
	private inline function get_type():Mime return new Mime(file.type);

	/* the date for the last time [this] File was modified */
	public var lastModified(get, never):Date;
	private inline function get_lastModified():Date {
		return file.lastModifiedDate;
	}

/* === Instance Fields === */

	private var file : NFile;
}

@:forward
abstract OldWebFile (NFile) from NFile {
	/* Constructor Function */
	public inline function new(f : NFile):Void {
		this = f;
	}

/* === Instance Fields === */

	/* The MIME Type of [this] File */
	public var type(get, never):Mime;
	private inline function get_type() return new Mime(this.type);

/* === Instance Methods === */

	/**
	  * Create an ObjectUrl
	  */
	public inline function getObjectURL():String {
		untyped {
			return Win.current.webkitURL.createObjectURL(this);
		};
	}
}
