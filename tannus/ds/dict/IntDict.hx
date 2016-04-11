package tannus.ds.dict;

import tannus.io.Ptr;

import haxe.ds.IntMap;
import haxe.Serializer;
import haxe.Unserializer;

class IntDict<T> implements IDict<Int, T> {
	/* Constructor Function */
	public function new():Void {
		m = new IntMap();
	}

/* === Instance Methods === */

	/* get a value */
	public inline function get(key : Int):Null<T> {
		return m.get( key );
	}

	public function set(k:Int, v:T):T {
		m.set(k, v);
		return m.get( k );
	}

	public function reference(key : Int):Ptr<T> {
		return new Ptr(m.get.bind(key), set.bind(key, _));
	}

	public inline function exists(k : Int):Bool return m.exists( k );

	public inline function remove(k : Int):Bool return m.remove( k );

	public inline function iterator():Iterator<T> return m.iterator();

	public inline function keys():Iterator<Int> return m.keys();

	public inline function pairs():IntDictPairIterator<T> return new IntDictPairIterator( this );

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
		m = new IntMap();
		for (i in 0...count) {
			set(u.unserialize(), u.unserialize());
		}
	}



/* === Instance Fields === */

	private var m : IntMap<T>;
}

@:access( tannus.ds.dict.IntDict )
class IntDictPairIterator<V> {
	public function new(d : IntDict<V>):Void {
		dict = d;
		it = dict.keys();
	}
	public function hasNext():Bool return it.hasNext();
	public function next():Pair<Int, V> {
		var k = it.next();
		return new Pair(k, dict.get( k ));
	}
	private var dict : IntDict<V>;
	private var it : Iterator<Int>;
}
