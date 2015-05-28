package tannus.chrome;

import tannus.chrome.Tab;

import tannus.ds.Object;
import tannus.ds.EitherType;

class BrowserAction {
	/**
	  * Register a Function to be run when the BrowserAction's Icon is clicked
	  */
	public static function onClick(func : Tab->Void):Void {
		lib.onClicked.addListener(function(t : Tab) {
			func( t );
		});
	}

	/**
	  * Set Popup
	  */
	public static function setPopup(popup:String, ?id:Int):Void {
		lib.setPopup({
			'tabId' : id,
			'popup': popup
		});
	}

	/**
	  * Set Title
	  */
	public static function setTitle(title:String, ?id:Int):Void {
		lib.setTitle({
			'tabId' : id,
			'title' : title
		});
	}

	/**
	  * Get Title
	  */
	public static function getTitle(tab_id:Null<Int>, cb:String->Void):Void {
		lib.getTitle({
			'tabId' : tab_id
		}, cb);
	}

	/**
	  * Set Icon
	  */
	public static function setIcon(img:EitherType<String, Dynamic>, ?id:Int, ?cb:Void->Void):Void {
		var opts:Object = {};
		if (id != null)
			opts['tabId'] = id;

		switch (img.type) {
			case Left( str ):
				opts['path'] = str;

			case Right( obj ):
				opts['imageData'] = obj;
		}

		lib.setIcon(opts, function() {
			if (cb != null)
				cb();
		});
	}
	
	/**
	  * Object used internally by [this] Class
	  */
	public static var lib(get, never):Dynamic;
	private static inline function get_lib():Dynamic {
		return untyped __js__('chrome.browserAction');
	}
}
