package tannus.chrome;

import tannus.chrome.Windows;
import tannus.chrome.Tab;
import tannus.ds.Object;

import tannus.chrome.TabData.TabCreateData;
import tannus.chrome.TabData.TabUpdateData;

class Tabs {
	/**
	  * Get All Tabs
	  */
	public static function getAll(callb : Array<Tab>->Void):Void {
		Windows.getAll(function(wins) {
			var tablist:Array<Tab> = new Array();

			for (win in wins) {
				var tabs:Array<Tab> = cast win.tabs;

				tablist = tablist.concat( tabs );
			}

			callb( tablist );
		});
	}

	/**
	  * Perform a Query on all Tabs
	  */
	public static function query(queryStr:String, cb:Array<Tab>->Void):Void {
		getAll(function( tabs ) {
			var otabs:Array<Object> = (cast tabs);

			var results = otabs.filter(function(t) return t.is(queryStr));

			cb(cast results);
		});
	}

	/**
	  * Get Current Tab
	  */
	public static inline function getCurrent(cb : Tab->Void):Void {
		lib.getCurrent( cb );
	}

	/**
	  * Get Tab by id
	  */
	public static inline function get(id:Int, cb:Tab->Void):Void {
		lib.get(id, cb);
	}

	/**
	  * Create a new Tab
	  */
	public static function create(options:TabCreateData, ?cb:Tab->Void):Void {
		lib.create(options, cb);
	}

	/**
	  * Update a Tab
	  */
	public static function update(id:Null<Int>, props:TabUpdateData, ?cb:Tab->Void):Void {
		lib.update(id, props, function(tab) {
			if (cb != null)
				cb( tab );
		});
	}

	/**
	  * Reload a Tab
	  */
	public static function reload(id:Null<Int>, opts:Object, ?cb:Tab->Void):Void {
		lib.reload(id, opts, function(tab) {
			if (cb != null)
				cb( tab );
		});
	}

	/**
	  * Duplicate a Tab
	  */
	public static function duplicate(id:Null<Int>, ?cb:Tab->Void):Void {
		lib.duplicate(id, function( clone ) {
			if (cb != null)
				cb( clone );
		});
	}

	/**
	  * Move a Tab
	  */
	public static function move(id:Int, index:Int, ?windowId:Int, cb:Void->Void) {
		lib.move(id, {'windowId':windowId, 'index':index}, function(tab) {
			cb();
		});
	}

	/**
	  * Remove a Tab
	  */
	public static function remove(id:Null<Int>, ?cb:Void->Void):Void {
		lib.remove(id, function() {
			if (cb != null)
				cb();
		});
	}

	/**
	  * Execute JavaScript/CSS Code on a Tab
	  */
	public static function executeScript(id:Null<Int>, path:Null<String>, code:Null<String>, ?cb:Void->Void):Void {
		var opts:Object = {};
		if (path != null)
			opts['file'] = path;
		if (code != null)
			opts['code'] = code;

		lib.executeScript(id, opts, function(res) {
			if (cb != null)
				cb();
		});
	}

	/**
	  * Takes a URL, and searches for an open Tab with that URL
	  * if none is found, a new one is created and focus is shifted to it
	  */
	public static function focusOrCreateTab(url:String, ?cb:Tab->Void):Void {
		var t:Null<Tab> = null;

		getAll(function( tabs ) {
			for (tab in tabs) {
				if (tab.url == url) {
					t = tab;
				}
			}

			if (t != null) {
				t.update({
					'active': true
				}, function(tab) {
					if (cb != null)
						cb( tab );
				});
			}
			else {
				var opts:Object = {
					'url'      : url,
					'active' : true
				};

				create(opts, function(tab) {
					if (cb != null)
						cb( tab );
				});
			}
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
