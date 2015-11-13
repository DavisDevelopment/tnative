package tannus.chrome;

import tannus.ds.Object;
import tannus.ds.Maybe;
import tannus.ds.Delta;
import tannus.chrome.StorageArea;

class Storage {
	/**
	  * The object this class uses internally
	  */
	public static var lib(get, never):Dynamic;
	private static inline function get_lib():Dynamic return untyped __js__('chrome.storage');

	public static var local(get, never):StorageArea;
	private static inline function get_local() return cast lib.local;

	public static var sync(get, never):StorageArea;
	private static inline function get_sync() return cast lib.sync;

	/**
	  * Observe and handle changes to storage
	  */
	public static function onChange(listener : String -> StorageChange -> Void):Void {
		lib.onChanged.addListener(function(changes:Object, area:String) {
			var change:StorageChange = new StorageChange();
			for (key in changes.keys) {
				var c:TStorageChange<Dynamic> = cast changes.get(key);
				change.set(key, new Delta(c.newValue, c.oldValue));
			}

			listener(area, change);
		});
	}
}

typedef TStorageChange<T> = {
	?oldValue : T,
	?newValue : T
};

typedef StorageChange = Map<String, Delta<Dynamic>>;
