package tannus.ds;

import tannus.ds.Delta;
import tannus.ds.Pair;
import tannus.ds.Stack;
import tannus.ds.Object;

import tannus.io.Ptr;

//import haxe.Constraints.IMap;
import haxe.ds.StringMap;
import Map.IMap;

import haxe.macro.Expr;
import haxe.macro.Context;

using Lambda;
using tannus.ds.ArrayTools;

class MapTools {
	/**
	  * Obtain a Ptr reference to the given key of a Map
	  */
	public static macro function ref<K, V>(map:ExprOf<Map<K, V>>, key:ExprOf<K>):ExprOf<Ptr<V>> {
		var rem = (macro (function() $map.remove( $key )));
		var ref = (macro new tannus.io.Ptr($map.get.bind($key), $map.set.bind($key), $rem));
		return (macro $ref);
	}

	/**
	  * Create and return a shallow copy of the given Map
	  */
	/*
	@:generic
	public static function copy<K, V>(map : Map<K, V>):Map<K, V> {
		var c:Dynamic = Type.createInstance(Type.getClass(map), []);
		for (k in map.keys())
			c.set(k, map.get(k));
		return (untyped c);
	}
	*/

	/**
	  * Get the Array of Keys from a Map
	  */
	public static function keyArray<K,V>(self : Map<K,V>):Array<K> {
		return [for (k in self.keys()) k];
	}

	/**
	  * Calculate the 'delta' (difference) between two Maps
	  */
	@:generic
	public static function delta<K, V>(self:Map<K, V>, other:Map<K, V>):MapDelta<K, V> {
		var delta:MapDelta<K, V> = new MapDelta();
		for (key in self.keys()) {
			var curr:V = self.get( key );
			var next:Null<V> = other.get( key );
			if (next != null && next != curr) {
				delta.set(key, new Delta(curr, next));
			}
		}
		return delta;
	}

	/**
	  * Apply a MapDelta to a Map, like a Patch
	  */
	@:generic
	public static function apply<K, V>(target:Map<K, V>, patch:MapDelta<K, V>):Map<K, V> {
		var map:Map<K, V> = new Map();
		
		for (key in target.keys()) {
			map[key] = target[key];
		}

		for (key in patch.keys()) {
			map.set(key, patch.get(key).current);
		}
		
		return map;
	}

	/**
	  * Copy data from [source] to [o]
	  */
	public static function pull<K,V>(o:Map<K, V>, source:Map<K, V>):Void {
		for (key in source.keys()) {
			o[ key ] = source[ key ];
		}
	}

	/**
	  * Convert a Map to an Object
	  */
	public static function toObject<T>(self : Map<String, T>):Object {
		var o:Object = {};
		for (key in self.keys()) {
			o.set(key, self.get(key));
		}
		return o;
	}

    /**
      get an Array of key=>value pairs
     **/
	public static inline function pairs<T>(self:Map<String, T>):Array<Pair<String, T>> {
	    return [for (key in self.keys()) new Pair(key, self[key])];
	}
}

/* Type Shorthand for the Delta of two Maps */
private typedef MapDelta<K, V> = Map<K, Delta<V>>;
