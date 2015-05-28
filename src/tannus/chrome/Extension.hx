package tannus.chrome;

class Extension {
	/**
	  * Obtain a URL to a resource of [this] Extension
	  */
	public static function getURL(path : String):String {
		return cast lib.getURL( path );
	}
	
	/**
	  * Object used internally by [this] Class
	  */
	public static var lib(get, never):Dynamic;
	private static inline function get_lib():Dynamic {
		return untyped __js__('chrome.extension');
	}
}
