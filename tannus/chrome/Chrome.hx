package tannus.chrome;

import js.Browser;

class Chrome {
/* === Static Fields === */

	/**
	  * Whether the 'chrome' object even exists
	  */
	public static var supported(get, never):Bool;
	private static inline function get_supported():Bool {
		return (Browser.supported && (untyped __js__('\'chrome\' in window')));
	}

	/**
	  * Whether this is a Chrome extension
	  */
	public static var isExtension(get, never):Bool;
	private static inline function get_isExtension():Bool {
		return (supported && (untyped __js__("'extension' in window.chrome")));
	}

	/**
	  * Whether this is a Chrome Application
	  */
	public static var isApp(get, never):Bool;
	private static inline function get_isApp():Bool {
		return (supported && (untyped __js__("'app' in window.chrome")));
	}
}
