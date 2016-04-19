package tannus.mvc;

import tannus.mvc.Model;

class Attribute<T> {
	/* Constructor Function */
	public inline function new(m:Model, n:String):Void {
		model = m;
		name = n;
	}

/* === Instance Methods === */

	/**
	  * get the value of [this] Attribute
	  */
	public inline function get():T {
		return model.get( name );
	}

	/**
	  * set the value of [this] Attribute
	  */
	public inline function set(value : T):T {
		return model.set(name, value);
	}

	/**
	  * delete [this] Attribute
	  */
	public inline function delete():Bool {
		return model.remove( name );
	}

	/**
	  * check whether [this] Attribute exists
	  */
	public inline function exists():Bool {
		return model.exists( name );
	}

/* === Instance Fields === */

	/* the Model from which [this] Attribute is obtained */
	public var model : Model;

	/* the name of [this] Attribute */
	public var name(default, null) : String;
}
