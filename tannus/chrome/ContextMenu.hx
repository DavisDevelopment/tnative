package tannus.chrome;

import tannus.ds.Object;
import tannus.ds.Maybe;

class ContextMenu {

	/**
	  * Create a new Context Menu
	  */
	public static function create(options : Object):Void {
		lib.create( options );
	}
	
	/* Object used internally */
	public static var lib(get, never):Dynamic;
	private static inline function get_lib() return untyped __js__('chrome.contextMenus');
}
