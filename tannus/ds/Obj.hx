package tannus.ds;

import tannus.io.Ptr;

import Reflect in R;

using Reflect;

@:forward
abstract Obj (CObj) from CObj {
	/* Constructor Function */
	private inline function new(o : Dynamic):Void {
		this = CObj.create(o);
	}

/* === Instance Methods === */

	/**
	  * Cast to Dynamic
	  */
	@:to
	public inline function toDyn():Dynamic return this.o;

	/**
	  * Get an attribute of [this]
	  */
	@:arrayAccess
	public inline function get<T>(key:String):T 
		return this.get(key);

	/**
	  * Set an attribute of [this]
	  */
	@:arrayAccess
	public inline function set<T>(key:String, val:T):T
		return this.set(key, val);

/* === Class Methods === */

	/**
	  * Implicitly create a new Obj
	  */
	@:from
	public static inline function fromDynamic(d : Dynamic):Obj {
		return CObj.create( d );
	}
}

class CObj {
	/* Constructor Function */
	public function new(obj : Dynamic):Void {
		o = obj;
		refCache = new Map();
	}

/* === Instance Methods === */

	/**
	  * Get Array of all keys of [this] Obj
	  */
	public function keys():Array<String> {
		return o.fields();
	}

	/**
	  * Check for the given attribute
	  */
	public function exists(key : String):Bool {
		return o.hasField(key);
	}

	/**
	  * Get the value of the given attribute
	  */
	public function get<T>(key : String):T {
		return (untyped o.getProperty(key));
	}

	/**
	  * Set the value of the given attribute
	  */
	public function set<T>(key:String, val:T):T {
		o.setProperty(key, val);
		return get(key);
	}

	/**
	  * Get a Ptr reference to the given attribute
	  */
	public function field<T>(key : String):Ptr<T> {
		if (refCache.exists(key)) {
			return untyped refCache.get(key);
		}
		else {
			var ref:Ptr<T> = new Ptr(get.bind(key), set.bind(key, _), (function() remove(key)));
			refCache.set(key, untyped ref);
			return ref;
		}
	}

	/**
	  * Delete an attribute of [this]
	  */
	public function remove(key : String):Bool {
		return o.deleteField( key );
	}

	/**
	  * Copy [this] Obj
	  */
	public function clone():Obj {
		var klass:Null<Class<Dynamic>> = Type.getClass( o );
		if (klass != null) {
			var copi:Dynamic = Type.createEmptyInstance(cast klass);
			var ocopy:Obj = copi;
			for (k in keys()) {
				ocopy[k] = get(k);
			}
			return ocopy;
		}
		else {
			return R.copy(o);
		}
	}

/* === Instance Field === */

	@:allow(tannus.ds.Obj)
	private var o : Dynamic;
	private var refCache : Map<String, Ptr<Dynamic>>;

/* === Class Methods === */

	public static function create(o : Dynamic):CObj {
		if (Std.is(o, CObj))
			return cast o;
		else
			return new CObj( o );
	}
}
