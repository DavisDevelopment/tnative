package tannus.chrome;

import tannus.ds.Object;
import tannus.ds.Maybe;
import tannus.ds.Promise;
import tannus.ds.promises.*;

import tannus.chrome.Bookmark;
import tannus.chrome.Bookmark.*;

class Bookmarks {
	/**
	  * Search through the Bookmarks
	  */
	public static inline function search(query:String, cb:Array<Bookmark>->Void):Void {
		lib.search(query, cb);
	}

	/**
	  * Create a new Bookmark
	  */
	public static inline function raw_create(data:BookmarkCreateData, cb:Bookmark->Void):Void {
		lib.create(data, cb);
	}

	/**
	  * Get a Bookmark by id
	  */
	public static inline function raw_get(id:String, cb:Null<Bookmark>->Void):Void {
		lib.get(id, cb);
	}

	/**
	  * Get a Bookmark by id
	  */
	public static inline function get(id:String):Promise<Bookmark> {
		return Promise.create({
			raw_get(id, function(bm) {
				if (bm == null)
					throw 'Bookmark with id "$id" was not found!';
				else
					return bm;
			});
		});
	}

	/**
	  * Get a Bookmark tree
	  */
	public static inline function getSubTree(id : String):ArrayPromise<Bookmark> {
		return Promise.create({
			lib.getSubTree(id, function(data) {
				return data[0].children;
			});
		}).array();
	}

	/**
	  * Create a new Bookmark
	  */
	public static inline function create(data : BookmarkCreateData):Promise<Bookmark> {
		return Promise.create({
			raw_create(data, function(bookmark) {
				return bookmark;
			});
		});
	}

	/**
	  * Remove a Bookmark
	  */
	public static inline function remove(id:String, cb:Void->Void):Void {
		lib.remove(id, cb);
	}
	
	/**
	  * Internal Reference
	  */
	public static var lib(get, never):Dynamic;
	private static inline function get_lib() {
		return (untyped __js__('chrome.bookmarks'));
	}
}

