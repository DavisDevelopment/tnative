package tannus.html.fs;

import tannus.html.fs.WebFileEntry;

import js.html.File in NFile;
import tannus.html.Win;
import tannus.sys.Mime;

@:forward
abstract WebFile (NFile) from NFile {
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
