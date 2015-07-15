package tannus.chrome;

import tannus.ds.Object;
import tannus.ds.Promise;
import tannus.ds.promises.ArrayPromise;

import tannus.chrome.Window;
import tannus.chrome.WindowData;

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
	  * Retrieve a Promise of a List of All Windows
	  */
	public static function all():ArrayPromise<Window> {
		return Promise.create({
			try {
				getAll(function( wins ) {
					return wins;
				});
			} catch (err : Dynamic) {
				throw err;
			}
		}).array();
	}

	/**
	  * Retrieve a reference to a Window by it's ID
	  */
	public static function get(id : Int):Promise<Window> {
		return Promise.create({
			lib.get(id, {'populate':true}, function(win : Null<Window>) {
				if (win != null)
					return win;
				else
					throw 'Window not found';
			});
		});
	}

	/**
	  * Create a Window
	  */
	public static function create(data : Object):Promise<Window> {
		return Promise.create({
			var wd:WindowData = data;

			lib.create(wd, function(win : Window) {
				return win;
			});
		});
	}

	/**
	  * Update a Window by id
	  */
	public static function update(id:Int, changes:Object):Promise<Window> {
		return Promise.create({
			lib.update(id, changes, function(win : Window) {
				return win;
			});
		});
	}

	/**
	  * Remove a Window by id
	  */
	public static inline function remove(id:Int, cb:Void->Void) {
		lib.remove(id, cb);
	}

	/**
	  * Reference to the standard 'windows' object
	  */
	public static var lib(get, never):Dynamic;
	private static inline function get_lib():Dynamic {
		return untyped __js__('chrome.windows');
	}
}


