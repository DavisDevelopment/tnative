package tannus.chrome;

import tannus.ds.Object;
import tannus.ds.Delta;
import tannus.ds.Maybe;
import tannus.chrome.Storage;

@:forward
abstract StorageArea (CStorageArea) from CStorageArea {
	/* Constructor Function */
	public inline function new(a : CStorageArea):Void {
		this = a;
	}

/* === Instance Methods === */

	/**
	  * Register a Listener for any change occurring on [this] Area
	  */
	public inline function onChange(cb : StorageChange -> Void):Void {
		Storage.onChange(function(area, changes) {
			switch ( area ) {
				case 'local' if (this == Storage.local):
					cb( changes );

				case 'sync' if (this == Storage.sync):
					cb( changes );

				default:
					null;
			}
		});
	}

	/**
	  * Register a Listener for changes on a specific item in [this] Area
	  */
	public inline function onChangeField<T:Dynamic>(key:String, cb:Delta<T> -> Void):Void {
		onChange(function( changes ) {
			/* when [key] is one of the fields that was changed */
			if (changes.exists( key )) {
				var d:Delta<Dynamic> = changes.get( key );
				cb(untyped d);
			}
		});
	}

	/**
	  * Watch the given field
	  */
	public function watch<T>(key:String, cb:Delta<T> -> Void):Void {
		onChangeField(key, function(change) {
			trace( change );
		});
	}

	/**
	  * Watch the whole area
	  */
	public function watchAll(cb : StorageChange -> Void):Void {
		onChange( cb );
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
