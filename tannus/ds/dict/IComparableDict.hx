package tannus.ds.dict;

import tannus.ds.IComparable;
import tannus.io.Ptr;
import haxe.ds.BalancedTree;

import haxe.Serializer;
import haxe.Unserializer;

class IComparableDict<K:IComparable<K>, V> implements IDict<K, V> {
	/* Constructor Function */
	public function new():Void {
		t = new IComparableTree();
	}

/* === Instance Methods === */

	public inline function get(key : K):Null<V> return t.get(key);
	public function set(key:K, value:V):V {
		t.set(key, value);
		return t.get( key );
	}
	public function reference(key : K):Ptr<V> {
		return new Ptr(t.get.bind( key ), set.bind(key, _));
	}
	public inline function exists(key : K):Bool return t.exists( key );
	public inline function remove(key : K):Bool return t.remove( key );
	public inline function iterator():Iterator<V> return t.iterator();
	public inline function keys():Iterator<K> return t.keys();
	public inline function pairs():ICDPairIterator<K, V> {
		return new ICDPairIterator( this );
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
		var count:Int = u.unserialize();
		t = new IComparableTree();
		for (i in 0...count) {
			set(u.unserialize(), u.unserialize());
		}
	}

/* === Instance Fields === */

	private var t : IComparableTree<K, V>;
}

class IComparableTree<K:IComparable<K>, V> extends BalancedTree<K, V> {
	override function compare(x:K, y:K):Int {
		return (x.compareTo( y ));
	}
}

class ICDPairIterator<K:IComparable<K>, V> {
	private var d:IComparableDict<K, V>;
	private var i:Iterator<K>;
	public function new(dict : IComparableDict<K, V>) {
		d = dict;
		i = d.keys();
	}
	public function hasNext():Bool return i.hasNext();
	public function next():Pair<K, V> {
		var k = i.next();
		return new Pair(k, d.get( k ));
	}
}
