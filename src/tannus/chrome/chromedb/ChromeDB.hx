package tannus.chrome.chromedb;

import tannus.chrome.StorageArea;

import tannus.ds.Object;
import tannus.ds.Promise;
import tannus.ds.promises.*;

import tannus.chrome.chromedb.StackData;

class ChromeDb {
	/* Constructor Function */
	public function new(store : StorageArea):Void {
		area = store;
		data = new StackData();
		pull
	}

/* === Instance Methods === */

	/**
	  * Perform initial setup
	  */
	public function setup():BoolPromise {
		return install( area );
	}

	/**
	  * Pull the stored Stack Data onto the local one
	  */
	public function pull(cb : Void->Void):Void {
		area.get(KEY, function(o : Object) {
			var stored:String = (o[KEY] + '');
			data.decode( stored );
			cb();
		});
	}

	/**
	  * Sync the local data onto the Stored one
	  */
	private function sync(cb : Void->Void) {
		var o:Object = {};
		o[KEY] = data.encode();
		area.set(o, function() {
			cb();
		});
	}

/* === Instance Fields === */

	//- The StorageArea [this] is using
	public var area : StorageArea;

	public var data : StackData;

/* === Static Methods === */
	
	/**
	  * 'install' ChromeDB on the StorageArea provided
	  */
	public static function install(area : StorageArea):BoolPromise {
		return Promise.create({
			area.get(KEY, function(data : Object) {
				if (!data.exists( KEY )) {
					var o:Object = {};
					
					area.set(o, function() {
						return true;
					});
				}
				else {
					return false;
				}
			});
		}).bool();
	}

/* === Static Fields === */

	/* The key under which to store the databases */
	public static inline var KEY:String = 'chromedb';
}
