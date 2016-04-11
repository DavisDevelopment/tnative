package tannus.chrome;

import tannus.html.fs.*;

class SyncFileSystem {
/* === Static Methods === */

	/**
	  * Request a FileSystem to work with
	  */
	public static inline function requestFileSystem(cb : WebFileSystem -> Void):Void {
		lib.requestFileSystem( cb );
	}

/* === Static Fields === */

	private static var lib(get, never):Dynamic;
	private static inline function get_lib():Dynamic return (untyped __js__('chrome.syncFileSystem'));
}
