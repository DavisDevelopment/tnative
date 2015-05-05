package tannus.chrome;

import tannus.ds.Object;
import tannus.ds.Maybe;

@:forward
abstract StorageArea (CStorageArea) from CStorageArea {
	/* Constructor Function */
	public inline function new(a : CStorageArea):Void {
		this = a;
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
