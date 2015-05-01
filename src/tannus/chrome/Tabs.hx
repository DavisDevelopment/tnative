package tannus.chrome;

import tannus.chrome.Windows;
import tannus.ds.Object;

class Tabs {
	/**
	  * Get All Tabs
	  */
	public static function getAll(callb : Array<Dynamic>->Void):Void {
		Windows.getAll(function(wins) {
			var tablist:Array<Dynamic> = new Array();

			for (win in wins) {
				tablist = tablist.concat(win.tabs);
			}

			var tabs:Array<Dynamic> = tablist.map(function(tab) {
				return tab;
			});

			callb( tabs );
		});
	}

	/**
	  * Reference to the object being used internally
	  */
	public static var lib(get, never):Dynamic;
	private static inline function get_lib():Dynamic {
		return untyped __js__('chrome.tabs');
	}
}
