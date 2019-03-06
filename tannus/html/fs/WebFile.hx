package tannus.html.fs;

import tannus.html.fs.WebFileEntry;

import js.html.File in NFile;
import js.html.FileReader;
import js.html.Blob;

import tannus.ds.Promise;
import tannus.io.ByteArray;
import tannus.html.Win;
import tannus.sys.Mime;

import tannus.math.TMath.*;

using tannus.math.TMath;

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
				throw error.target.error;
			};
			reader.onload = function(event) {
				var data:ByteArray = ByteArray.ofData(cast event.target.result);
				return data;
			};

			if (pos == 0 && len == size) {
				reader.readAsArrayBuffer(cast file);
			}
			else {
				reader.readAsArrayBuffer(slice(pos, (pos + len), type));
			}
		});
	}

	/**
	  * Create and return a new FileReader instance attached to [this]
	  */
	public inline function createReader():WebFileReader {
		return new WebFileReader( this );
	}

	/**
	  * Create and return a ReadableByteStream bound to [this] File
	  */
	public inline function input():WebFileInput {
		return new WebFileInput( this );
	}

	/**
	  * get an 'Object URL' for [this] File
	  */
	public function getObjectURL():String {
		if (_objectUrl == null) {
			var w = Win.current;
			var getter:NFile -> String = (untyped __js__('(w.URL || w.webkitURL).createObjectURL.bind(w)'));
			_objectUrl = getter( file );
		}
		return _objectUrl;
	}

	public inline function getNativeFile():NFile return file;

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
	    #if (haxe_ver >= 4)
		return Date.fromTime( file.lastModified );
		#else
		return file.lastModifiedDate;
		#end
	}

#if (node || node_webkit || electron)

	public var path(get, never):String;
	private inline function get_path():String return (untyped file).path;

#end

/* === Instance Fields === */

	private var file : NFile;
	private var _objectUrl : Null<String> = null;
}

class WebFileReader {
	public function new(f : WebFile):Void {
		file = f;
		r = new FileReader();
		offset = 0;
	}

	/* move [offset] to the given value */
	public inline function seek(pos : Int):Int {
		return (offset = pos.clamp(0, file.size));
	}

	/* read a chunk of data */
	public function read(?size:Int, provide:ByteArray->Void, reject:Dynamic->Void):Void {
		if (size == null) {
			size = (file.size - offset);
		}
		size = min(size, (file.size - offset));

		r.onload = (function(event) {
			offset += size;
			if (offset == file.size) {
				r = null;
			}

			try {
				provide(ByteArray.ofData(cast event.target.result));
			}
			catch (error : Dynamic) {
				reject( error );
			}
		});
		r.onerror = reject.bind( _ ); //(function(error) reject( error ));
		r.readAsArrayBuffer(file.slice(offset, (offset + size)));
	}

	private var file : WebFile;
	private var r : FileReader;
	private var offset : Int;
}
