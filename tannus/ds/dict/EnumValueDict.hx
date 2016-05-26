package tannus.ds.dict;

import tannus.io.Ptr;

import haxe.ds.EnumValueMap;
import haxe.Serializer;
import haxe.Unserializer;

class EnumValueDict<K:EnumValue, V> implements IDict<K, V> {
	/* Constructor Function */
	public function new():Void {
		m = new EnumValueMap();
	}

/* === Instance Methods === */

	/* get a value */
	public inline function get(key : K):Null<V> {
		return m.get( key );
	}

	public function set(k:K, v:V):V {
		m.set(k, v);
		return m.get( k );
	}

	public function reference(key : K):Ptr<V> {
		return new Ptr(m.get.bind(key), set.bind(key, _));
	}

	public inline function exists(k : K):Bool return m.exists( k );

	public inline function remove(k : K):Bool return m.remove( k );

	public inline function iterator():Iterator<V> return m.iterator();

	public inline function keys():Iterator<K> return m.keys();

	public inline function pairs():EVDPairIterator<K, V> return new EVDPairIterator( this );

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
		m = new EnumValueMap();
		for (i in 0...count) {
			set(u.unserialize(), u.unserialize());
		}
	}



/* === Instance Fields === */

	private var m : EnumValueMap<K, V>;
}

@:access( tannus.ds.dict.EnumValueDict )
class EVDPairIterator<K:EnumValue, V> {
	public function new(d : EnumValueDict<K, V>):Void {
		dict = d;
		it = dict.m.keys();
	}
	public function hasNext():Bool return it.hasNext();
	public function next():Pair<K, V> {
		var k = it.next();
		return new Pair(k, dict.get( k ));
	}
	private var dict : EnumValueDict<K, V>;
	private var it : Iterator<K>;
}
