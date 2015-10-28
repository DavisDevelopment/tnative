package tannus.ds;

import tannus.ds.Object;
import tannus.ds.Maybe;
import tannus.ds.TwoTuple;
import tannus.ds.EitherType;

abstract Dict<K, V> (CDict<K, V>) from CDict<K, V> {
	/* Constructor Function */
	public inline function new(?cd : CDict<K, V>):Void {
		this = (cd != null ? cd : new CDict<K, V>());
	}

	/**
	  * Iterate over [this] Dict
	  */
	public inline function iterator():Iterator<Pair<K, V>> {
		return cast this.pairs.iterator();
	}

	/**
	  * Access values by with array-acess
	  */
	@:arrayAccess
	public inline function get(k : K):Null<V> {
		return (this.get( k ));
	}

	/**
	  * Assign values with array-access
	  */
	@:arrayAccess
	public inline function set(k:K, v:V):V {
		return this.set(k, v);
	}

	/**
	  * Reassign a key, by value
	  */
	public inline function setKey(v:V, k:K):K {
		return this.setByValue(k, v);
	}

	/**
	  * Remove a key,value Pair by key
	  */
	public function remove(id : EitherType<K, V>):Void {
		switch (id.type) {
			case Left(key):
				this.removeByKey( key );

			case Right(val):
				this.removeByValue( val );
		}
	}

	/**
	  * Determine whether [this] Dict has a property by the given name
	  */
	public inline function exists(key : K):Bool {
		return (get(key) != null);
	}

	/**
	  * Append data from another Dict onto [this] one
	  */
	@:op(A += B)
	public inline function write_a(other : Dict<K, V>) {
		this.write(other);
	}

	/**
	  * Cast [this] Dict implicitly to an Object
	  */
	@:to
	public inline function toObject():Object {
		var o:Object = {};
		for (p in iterator()) 
			o.set(p.key+'', p.value);
		return o;
	}
}

/**
  * Underlying Type for tannus.ds.Dict<K, V>
  */
@:generic
class CDict<K, V> {
	/* Constructor Function */
	public function new():Void {
		pairs = new List();
	}

/* === Instance Methods === */

	/**
	  * Get a Value
	  */
	public function get(key : K):Null<V> {
		var pair:Null<TwoTuple<K, V>> = getPairByKey(key);
		
		return (pair!=null?pair.two:null);
	}

	/**
	  * Set a Value
	  */
	public inline function set(k:K, v:V):V {
		return setByKey(k, v);
	}

	/**
	  * Find a Pair by key
	  */
	private function getPairByKey(key : K):Maybe<TwoTuple<K, V>> {
		for (p in pairs)
			if (p.one == key)
				return p;
		return null;
	}

	/**
	  * Find a Pair by value
	  */
	private function getPairByValue(value : V):Maybe<TwoTuple<K, V>> {
		for (p in pairs)
			if (p.two == value)
				return p;
		return null;
	}

	/**
	  * Assign a value by key
	  */
	private function setByKey(k:K, v:V):V {
		var p = getPairByKey(k);
		if (p)
			p.toNonNullable().two = v;
		else
			pairs.add(new TwoTuple(k, v));
		return v;
	}

	/**
	  * Assign a key by value
	  */
	public function setByValue(k:K, v:V):K {
		var p = getPairByValue( v );
		if (p)
			p.toNonNullable().one = k;
		else
			pairs.add(new TwoTuple(k, v));
		return k;
	}

	/**
	  * Delete a Pair, identified by key
	  */
	public function removeByKey(key : K):Void {
		pairs.remove(getPairByKey(key));
	}

	/**
	  * Delete a Pair, identified by value
	  */
	public function removeByValue(val : V):Void {
		pairs.remove(getPairByValue(val));
	}

	/**
	  * Copy all data from [other] onto [this]
	  */
	public function write(other : Dict<K, V>):Void {
		for (pair in other)
			set(pair.key, pair.value);
	}

/* === Instance Fields === */

	public var pairs:List<TwoTuple<K, V>>;
}

/**
  * Wrapper abstract
  */
private abstract Pair<Key, Value> (TwoTuple<Key, Value>) from TwoTuple<Key, Value> {
	public inline function new(p : TwoTuple<Key, Value>) {
		this = p;
	}

	public var key(get, set):Key;
	private inline function get_key() return this.one;
	private inline function set_key(nk) return (this.one = nk);

	public var value(get, set):Value;
	private inline function get_value() return this.two;
	private inline function set_value(nv) return (this.two = nv);

	@:to
	public inline function toArray():Array<Dynamic> {
		var a:Array<Dynamic> = [key, value];
		return a;
	}
}
