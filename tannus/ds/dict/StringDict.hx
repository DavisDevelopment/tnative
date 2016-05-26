package tannus.ds.dict;

import tannus.io.Ptr;

import haxe.ds.StringMap;
import haxe.Serializer;
import haxe.Unserializer;

class StringDict<T> implements IDict<String, T> {
	/* Constructor Function */
	public function new():Void {
		m = new StringMap();
	}

/* === Instance Methods === */

	/* get a value */
	public inline function get(key : String):Null<T> {
		return m.get( key );
	}

	public function set(k:String, v:T):T {
		m.set(k, v);
		return m.get( k );
	}

	public function reference(key : String):Ptr<T> {
		return new Ptr(m.get.bind(key), set.bind(key, _));
	}

	public inline function exists(k : String):Bool return m.exists( k );

	public inline function remove(k : String):Bool return m.remove( k );

	public inline function iterator():Iterator<T> return m.iterator();

	public inline function keys():Iterator<String> return m.keys();

	public inline function pairs():StringDictPairIterator<T> return new StringDictPairIterator( this );

	/**
	  * Serialize [this] Dict
	  */
	@:keep
	public function hxSerialize(s : Serializer):Void {
		var w = s.serialize.bind( _ );

		var pl = [for (pair in pairs()) pair];
		w( pl.length );
		for (p in pl) {
			w( p.key );
			w( p.value );
		}
	}

	/**
	  * unserialize [this] Dict
	  */
	@:keep
	public function hxUnserialize(u : Unserializer):Void {
		var count:Int = u.unserialize();
		m = new StringMap();
		for (i in 0...count) {
			set(u.unserialize(), u.unserialize());
		}
	}

/* === Instance Fields === */

	private var m : StringMap<T>;
}

@:access( tannus.ds.dict.StringDict )
class StringDictPairIterator<V> {
	public function new(d : StringDict<V>):Void {
		dict = d;
		it = dict.keys();
	}
	public function hasNext():Bool return it.hasNext();
	public function next():Pair<String, V> {
		var k = it.next();
		return new Pair(k, dict.get( k ));
	}
	private var dict : StringDict<V>;
	private var it : Iterator<String>;
}
