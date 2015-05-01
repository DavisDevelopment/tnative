package tannus.ds;

import tannus.ds.Maybe;

/**
  * Allows for the use of any Dynamic object as if it were a Map
  */
abstract Object (Dynamic) from Dynamic {
	/* Constructor Function */
	public inline function new(o : Dynamic):Void {
		this = o;
	}

/* === Instance Fields === */

	/**
	  * Returns a list of all keys
	  */
	public var keys(get, never):Array<String>;
	private inline function get_keys():Array<String> {
		return Reflect.fields(this);
	}

/* === Instance Methods === */

	/**
	  * Field Access
	  */
	@:arrayAccess
	public inline function get(key : String):Maybe<Dynamic> {
		return Reflect.getProperty(this, key);
	}

	/**
	  * Field Assignment
	  */
	@:arrayAccess
	public inline function set(key:String, value:Dynamic):Null<Dynamic> {
		Reflect.setProperty(this, key, value);
		return get(key);
	}

	/**
	  * Check for the existence of a field with the given key
	  */
	public inline function exists(key : String):Bool {
		return Reflect.hasField(this, key);
	}

	/**
	  * Delete a field
	  */
	public inline function remove(key : String):Void {
		Reflect.deleteField(this, key);
	}

	/**
	  * Do Stuff
	  */
	public inline function pairs():Array<{name:String, value:Dynamic}> {
		return keys.map(function(k) return {'name':k, 'value':get(k)});
	}

	/**
	  * Iterate
	  */
	public inline function iterator():Iterator<{name:String, value:Dynamic}> {
		return (pairs().iterator());
	}
}
