package tannus.mvc;

import tannus.ds.Delta;
import tannus.storage.Storage;
import tannus.mvc.Model.ModelChange;

class StoredModel extends Model {
	/* Constructor Function */
	public function new():Void {
		super();
	}

/* === Instance Methods === */

	/* get an attribute */
	override public function getAttribute<T>(key : String):T {
		return storage.get(map_key( key ));
	}

	/* set an attribute */
	override public function setAttribute<T>(key:String, value:T):T {
		var c = {
			name : key,
			value : new Delta(value, get( key ))
		};
		var curr:T = storage.set(map_key( key ), value);
		change.call( c );
		return curr;
	}

	/* remove an attribute */
	override public function removeAttribute(key : String):Bool {
		var c = {
			name : map_key( key ),
			value : new Delta(null, get( key ))
		};

		var had = storage.exists(map_key( key ));
		storage.remove(map_key( key ));
		change.call( c );
		return had;
	}

	/* check for presence of an attribute */
	override public function hasAttribute(key : String):Bool {
		return storage.exists(map_key( key ));
	}

	/* get an array of all attribute keys */
	override public function allAttributes():Array<String> {
		return storage.keys();
	}

	/**
	  * transform attribute-keys
	  */
	public function map_key(key : String):String {
		return key;
	}

	/**
	  * Sync [this] Model with it's remote
	  */
	override public function sync(f : Void -> Void):Void {
		storage.fetch(function() {
			storage.push( f );
		});
	}

	/**
	  * Delete all local changes to [storage], and re-fetch the remote
	  */
	public function rollback(?cb : Void->Void):Void {
		storage.rollback();
		storage.fetch(function() {
			if (cb != null) cb();
		});
	}

/* === Computed Instance Fields === */

	/* the Storage instance in use by [this] Model */
	public var storage(default, set):Null<Storage>;
	private function set_storage(v : Null<Storage>):Null<Storage> {
		storage = v;
		readyReqs.add('storage', function(met) {
			storage.init( met );
		});
		return storage;
	}
}
