package tannus.chrome;

import tannus.ds.Object;
import tannus.ds.Maybe;
import tannus.chrome.Storage;

@:forward
abstract StorageArea (CStorageArea) from CStorageArea {
	/* Constructor Function */
	public inline function new(a : CStorageArea):Void {
		this = a;
	}

/* === Instance Methods === */

	public inline function onChange(cb : Object->Void):Void {
		Storage.onChange(function(area, changes) {
			if (area == 'local' && this == Storage.local) {
				cb( changes );
			}
			else if (area == 'sync' && this == Storage.sync) {
				cb( changes );
			}
		});
	}
}

extern class CStorageArea {
	/* Retrieve Some Data Asynchronously */
	function get(data:Object, cb:Dynamic->Void):Void;

	/* Set some Data */
	function set(data:Object, cb:Void->Void):Void;

	function remove(keys:Array<String>, cb:Void->Void):Void;

	function clear(?cb:Void->Void):Void;
}
