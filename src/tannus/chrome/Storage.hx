package tannus.chrome;

import tannus.ds.Object;
import tannus.ds.Maybe;
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
}
