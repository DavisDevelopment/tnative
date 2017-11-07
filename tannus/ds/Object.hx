package tannus.ds;

import tannus.ds.Maybe;
import tannus.ds.Dict;
import tannus.nore.ORegEx;
import tannus.nore.Selector;

import haxe.macro.Expr;

using haxe.macro.ExprTools;
using tannus.macro.MacroTools;

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
	  * Raw Field Access
	  */
	public inline function rawget<T>(key : String):Null<T> {
		return untyped Reflect.getProperty(this, key);
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
	  * Create and return a clone of [this] Object
	  */
	public function clone():Object {
		var c:Object = {};
		for (k in keys)
			c[k] = get(k);
		return c;
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
	
	/**
	  * Write another Object anto [this] one
	  */
	@:op(A += B)
	public function increment(other : Object):Object {
		for (key in other.keys) {
			if (!exists( key )) {
				set(key, other.get(key));
			}
		}
		return new Object( this );
	}

	/**
	  * Get the 'sum' of [this] Object and another
	  */
	@:op(A + B)
	public function plus(other : Object):Object {
		var res:Object = clone();
		for (k in other.keys) {
			if (!res.exists(k))
				res[k] = other[k];
		}
		return res;
	}

	/**
	  * Write another object onto [this] one in-place
	  */
	public function write(o : Object):Void {
		for (k in o.keys)
			set(k, o[k]);
	}

	/**
	  * Obtain a method instance
	  */
	//public inline function method<T>(mname : String):Method<T> {
		//return new Method(get(mname), this);
	//}

    /**
      * invoke this[name] as a method of this, with [params]
      */
	public inline function call<T>(name:String, ?params:Array<Dynamic>):T {
	    return untyped Reflect.callMethod(this, get( name ), (params!=null?params:[]));
	}

	/**
	  * attempt to invoke this[name] as a method of this, with [params]
	  */
	public macro function tryCall<T>(self:ExprOf<Object>, name:ExprOf<String>, params:ExprOf<Null<Array<Dynamic>>>, failure:Expr):ExprOf<T> {
	    params = params.replace(macro _, self);
	    failure = failure.replace(macro _, self);
	    return macro {
	        var method:Null<Dynamic> = $self.get($name);
	        if (method != null) {
	            return untyped Reflect.callMethod($self, method, $params);
	        }
            else {
                return untyped $failure;
            }
	    };
	}

	/**
	  * get [this]'s [name] method
	  */
	public function method<T:Function>(name : String):T {
	    return Reflect.makeVarArgs(function(args) {
	        return call(name, args);
	    });
	}

	/**
	  * Pluck some data dopely
	  */
	/*
	public macro function pluck(self, firstKey:ExprOf<String>, otherKeys:Array<ExprOf<String>>) {
		otherKeys.unshift(firstKey);

		return macro $self._plk([$a{otherKeys}]);
	}
	*/

	/**
	  * Pluck by an Array
	  */
	public inline function plucka(keys : Array<String>):Object {
		return _plk( keys );
	}

	/**
	  * Pluck some data out of [this] Object
	  */
	@:noComplete
	public function _plk(keys:Array<String>, ?mtarget:Maybe<Object>):Object {
		var target:Object = (mtarget || {});
		for (k in keys) 
			target[k] = get(k);
		return target;
	}

	/**
	  * Determine if [this] Object is of type [type]
	  */
	public macro function istype(self, typ):ExprOf<Bool> {
		return macro Std.is($self, $typ);
	}

	/**
	  * Test [this] Object with an OReg
	  */
	public inline function is(oreg : String):Bool {
		var sel:Selector = oreg;
		return sel.test( this );
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

	/* From Map<String, Dynamic> */
	@:from
	public static function fromMap<T>(map : Map<String, T>):Object {
		var o:Object = new Object({});
		for (key in map.keys())
			o.set(key, map[key]);
		return o;
	}

	/* To Dict<String, Dynamic> */
	/*
	@:to
	public function toTannusDict():Dict<String, Dynamic> {
		var d:Dict<String, Dynamic> = new Dict();
		for (p in iterator())
			d.set(p.name, p.value);
		return d;
	}
	*/

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
