package tannus.html.fs;

import tannus.html.Win;
import tannus.html.fs.WebDirectoryEntry in Dir;

@:forward
abstract WebFileSystem (WebFS) from WebFS to WebFS {
	/* Constructor Function */
	private inline function new(w : WebFS):Void {
		this = w;
	}

	/**
	  * request a FileSystem for use
	  */
	public static inline function request(size:Int, cb:WebFileSystem->Void):Void {
		Win.current.requestFileSystem(size, cb);
	}
}

typedef WebFS = {
	var name : String;
	var root : Dir;
}
