package tannus.chrome;

import tannus.ds.Object;

class Windows {
	/**
	  * Retrieve List of All Windows
	  */
	public static function getAll(callb : Array<Window>->Void):Void {
		lib.getAll({'populate':true}, function(wins : Array<Window>) {
			callb( wins );
		});
	}

	/**
	  * Create a Window
	  */
	public static function create(data:Object, callb:Window->Void) {
		var wd:WindowData = data;

		lib.create(wd, function(win : Window) {
			callb( win );
		});
	}


	/**
	  * Reference to the standard 'windows' object
	  */
	public static var lib(get, never):Dynamic;
	private static inline function get_lib():Dynamic {
		return untyped __js__('chrome.windows');
	}
}

/**
  * Super Basic (Incomplete) Model of the Window Objects returned by chrome.windows.getAll()
  */
private typedef Window = {
	id : Int,
	type : String,
	state : String,
	focused : Bool,
	incognito : Bool,
	tabs : Array<Object>
};
