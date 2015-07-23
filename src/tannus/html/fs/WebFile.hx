package tannus.html.fs;

import tannus.html.fs.WebFileEntry;

import js.html.File in NFile;
import tannus.html.Win;

@:forward
abstract WebFile (NFile) from NFile {
	/* Constructor Function */
	public inline function new(f : NFile):Void {
		this = f;
	}

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
