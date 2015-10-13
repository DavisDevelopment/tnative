package tannus.chrome;

import tannus.ds.Object;

using Lambda;
using tannus.ds.ArrayTools;

class Cookies {
	/**
	  * Get a single Cookie
	  */
	public static inline function get(info:CookieInfo, cb:Null<Cookie>->Void):Void {
		lib.get(info, cb);
	}

	/**
	  * Get a batch of Cookies
	  */
	public static inline function getAll(filter:CookieFilter, cb:Array<Cookie>->Void):Void {
		lib.getAll(filter, cb);
	}
	
	/* object used internally */
	private static var lib(get, never):Dynamic;
	private static inline function get_lib() return (untyped __js__('chrome.cookies'));
}

typedef Cookie = {
	var name : String;
	var value : String;
	var domain : String;
	var hostOnly : Bool;
	var path : String;
	var secure : Bool;
	var httpOnly : Bool;
	var session : Bool;
	var storeId : String;
	@:optional var expirationDate : Float;
};

typedef CookieInfo = {
	url : String,
	name : String,
	?storeId : String
};

typedef CookieFilter = {
	?name : String,
	?url : String,
	?domain : String,
	?path : String,
	?secure : Bool,
	?session : Bool,
	?storeId : String
};
