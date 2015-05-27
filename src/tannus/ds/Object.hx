package tannus.ds;

import tannus.ds.Maybe;

/**
  * Allows for the use of any Dynamic object as if it were a Map
  */
abstract Object (Dynamic) from Dynamic to Dynamic {
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

/* === Implicit Casting === */

	/* To Map<String, Dynamic> */
	@:to
	public function toMap():Map<String, Dynamic> {
		var m:Map<String, Dynamic> = new Map();
		for (p in iterator()) {
			m.set(p.name, p.value);
		}
		return m;
	}

	#if python
		/* To Dict<String, Dynamic> */
		@:to
		public function toDict():python.Dict<String, Dynamic> {
			var d:python.Dict<String, Dynamic> = new python.Dict();
			for (p in iterator()) {
				d.set(p.name, p.value);
			}
			return d;
		}

		/* From Dict<String, Dynamic> */
		@:from
		public static function fromDict(d : python.Dict<String, Dynamic>):Object {
			var o:Object = {};
			for (p in d.items()) {
				o.set(p._1, p._2);
			}
			return o;
		}
	#end
}
