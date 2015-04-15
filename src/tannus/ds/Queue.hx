package tannus.ds;

import tannus.ds.Maybe;

/**
  * Abstract class which represents a 'Queue' of things, implemented as an Array
  */
@:forward(unshift, pop)
abstract Queue<T> (Array<T>) from Array<T> {
	/* Constructor Function */
	public inline function new(?a : Array<T>):Void {
		this = (a != null ? a : new Array());
	}

/* === Instance Methods === */

	/**
	  * Adds an item to the end of [this] Queue
	  */
	public inline function append(item : T):Void {
		this.push(item);
	}

	/**
	  * Adds an item to the beginning of [this] Queue
	  */
	public inline function prepend(item : T):Void {
		this.unshift(item);
	}

/* === Computed Instance Fields === */

	/**
	  * The first 'item' in [this] Queue
	  */
	public var first(get, set):Maybe<T>;
	private inline function get_first():Maybe<T> {
		return this[0];
	}
	private inline function set_first(nf : Maybe<T>):Maybe<T> {
		//- if [nf] is not [null], assign it as usual
		if (nf) {
			return (this[0] = nf);
		} else {
			return null;
		}
	}

	/**
	  * The last 'item' in [this] Queue
	  */
	public var last(get, set):Maybe<T>;
	private inline function get_last():Maybe<T> {
		return (this[this.length - 1]);
	}
	private inline function set_last(nl : Maybe<T>):Maybe<T> {
		if (nl) {
			return (this[this.length - 1] = nl);
		} else {
			return null;
		}
	}

	/**
	  * Get an item out of [this] Queue using ArrayAccess
	  */
	@:arrayAccess
	public inline function get(index : Int):Maybe<T> {
		return (this[index]);
	}

	/**
	  * Assign an item to [this] Queue using ArrayAccess
	  */
	@:arrayAccess
	public inline function set(index:Int, item:Maybe<T>):Maybe<T> {
		return (this[index] = item);
	}
}
