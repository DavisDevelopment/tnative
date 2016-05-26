package tannus.ds.dict;

import tannus.ds.Comparable;
import tannus.ds.Pair in CPair;
import tannus.io.Ptr;

import haxe.Serializer;
import haxe.Unserializer;

class ComparableDict<K:Comparable<K>, V> implements IDict<K, V> {
	/* Constructor Function */
	public function new():Void {
		_pairs = new List();
	}

/* === Instance Methods === */

	/**
	  * get the pair associated with the given key
	  */
	private function pair(key:K, ?value:V):Null<Pair<K, V>> {
		for (p in _pairs) {
			if (p.key.equals( key )) {
				return p;
			}
		}
		if (value != null) {
			var pair = new Pair(key, value);
			_pairs.add( pair );
			return pair;
		}
		else {
			return null;
		}
	}

	/**
	  * get a value
	  */
	public function get(key : K):Null<V> {
		var p = pair( key );
		if (p != null) {
			return p.value;
		}
		else {
			return null;
		}
	}

	/**
	  * set a value
	  */
	public function set(key:K, value:V):V {
		var p = pair(key, value);
		return (p.value = value);
	}

	/**
	  * obtain a Pointer to the given key
	  */
	public function reference(key : K):Ptr<V> {
		return new Ptr(get.bind( key ), set.bind(key, _));
	}

	/**
	  * check for existence of key
	  */
	public function exists(key : K):Bool {
		return (pair( key ) != null);
	}

	/**
	  * remove a key
	  */
	public function remove(key : K):Bool {
		var p = pair( key );
		if (p != null) {
			return _pairs.remove( p );
		}
		else {
			return false;
		}
	}

	/**
	  * iterate over the values of [this] Dict
	  */
	public function iterator():ComparableDictIterator<K, V> {
		return new ComparableDictIterator( this );
	}

	/**
	  * iterate over the keys of [this] Dict
	  */
	public function keys():ComparableDictKeyIterator<K, V> {
		return new ComparableDictKeyIterator( this );
	}

	/**
	  * iterate over [pairs]
	  */
	public function pairs():Iterator<Pair<K, V>> {
		return _pairs.iterator();
	}

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
		_pairs = new List();
		var count:Int = u.unserialize();
		for (i in 0...count) {
			set(u.unserialize(), u.unserialize());
		}
	}

/* === Instance Fields === */

	private var _pairs : List<Pair<K, V>>;
}

@:access( tannus.ds.dict.ComparableDict )
class ComparableDictIterator<K:Comparable<K>, V> {
	public function new(cd : ComparableDict<K, V>):Void {
		it = cd._pairs.iterator();
	}
	public inline function hasNext():Bool return it.hasNext();
	public inline function next():V return it.next().value;
	private var it : Iterator<Pair<K, V>>;
}

@:access( tannus.ds.dict.ComparableDict )
class ComparableDictKeyIterator<K:Comparable<K>, V> {
	public function new(cd : ComparableDict<K, V>):Void {
		it = cd._pairs.iterator();
	}
	public inline function hasNext():Bool return it.hasNext();
	public inline function next():K return it.next().key;
	private var it : Iterator<Pair<K, V>>;
}
