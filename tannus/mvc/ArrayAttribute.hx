package tannus.mvc;

import tannus.mvc.Model;

class ArrayAttribute<T> extends Attribute<Array<T>> {
	/* Constructor Function */
	public function new(model:Model, name:String):Void {
		super(model, name);

		change.on(function(d) altered = true);
	}

/* === Instance Methods === */

	/**
	  * Get the value of [this] Attribute
	  */
	override public function get():Array<T> {
		if (arr == null || altered) {
			recache();
		}
		return arr.copy();
	}

	/**
	  * Set the value of [this] Attribute
	  */
	override public function set(value : Array<T>):Array<T> {
		super.set(untyped encode( value ));
		return value;
	}

	/**
	  * Get the value stored in [this] Array at the given index
	  */
	public function getItem(index : Int):Null<T> {
		return (get()[ index ]);
	}

	/**
	  * Set the value stored at [index] (if any)
	  */
	public function setItem(index:Int, value:T):T {
		var list = get();
		var res:T = (list[index] = value);
		set( list );
		return res;
	}

	/**
	  * Get the result of concatenating [this] Array and [a]
	  */
	public function concat(a : Array<T>):Array<T> {
		return (get().concat( a ));
	}

	/**
	  * Append the given Array to [this] one
	  */
	public function append(a : Array<T>):Void {
		set(concat( a ));
	}

	public function filter(test : T -> Bool):Array<T> return get().filter( test );

	/**
	  * Re-assign [this] to the result of filtering [this] by [test]
	  */
	public function ifilter(test : T -> Bool):Void {
		set(filter( test ));
	}

	/**
	  * return the position of the first occurrence of [x]
	  */
	public function indexOf(x:T, fromIndex:Int=0):Int {
		return (get().indexOf(x, fromIndex));
	}

	/**
	  * insert [x] into [this] at [index]
	  */
	public function insert(x:T, index:Int):Void {
		var list = get();
		list.insert(index, x);
		set( list );
	}

	/**
	  * returns a String representation of [this] Array, with [sep] separating each item
	  */
	public function join(sep : String):String {
		return get().join( sep );
	}

	/**
	  * returns the position of the last occurrence of [x]
	  */
	public function lastIndexOf(x : T):Int {
		return get().lastIndexOf( x );
	}

	/**
	  * Creates and returns a new Array by applying [f] to all items in [this]
	  */
	public function map<A>(f : T -> A):Array<A> {
		return get().map( f );
	}

	/**
	  * Removes and returns the last Element in [this] Array
	  */
	public function pop():Null<T> {
		var list = get();
		var res = list.pop();
		set( list );
		return res;
	}

	/**
	  * add [x] to the end of [this] Array
	  */
	public function push(x : T):Int {
		var list = get();
		var res = list.push( x );
		set( list );
		return res;
	}

	/**
	  * remove the first occurrence of [x] in [this]
	  */
	public function remove(x : T):Bool {
		var list = get();
		var res = list.remove( x );
		set( list );
		return res;
	}

	/**
	  * reverse [this] Array in place
	  */
	public function reverse():Void {
		var list = get();
		list.reverse();
		set( list );
	}

	/**
	  * remove and return the first item in [this] Array
	  */
	public function shift():Null<T> {
		var list = get();
		var res = list.shift();
		set( list );
		return res;
	}

	/* return a shallow copy of the specified range */
	public function slice(pos:Int, ?end:Int):Array<T> return get().slice(pos, end);

	/**
	  * sort [this] Array in place
	  */
	public function sort(sorter : T -> T -> Int):Void {
		var list = get();
		haxe.ds.ArraySort.sort(list, sorter);
		set( list );
	}

	/**
	  * removes [len] items from [this] Array, starting at and including [index]
	  */
	public function splice(index:Int, len:Int):Array<T> {
		var list = get();
		var res = list.splice(index, len);
		set( list );
		return res;
	}

	/**
	  * add [x] to the start of [this] Array
	  */
	public function unshift(x : T):Void {
		var list = get();
		list.unshift( x );
		set( list );
	}

	/**
	  * Method used to transform [this] Attribute into an Array<T>
	  * (from whatever it may be stored as on the backend)
	  */
	public dynamic function decode(back : Dynamic):Array<T> {
		// by default, Arrays are stored simply as Arrays
		return untyped back;
	}

	/**
	  * Method used to transform [this] Attribute's value into 
	  * whatever format is being used to store it on the backend
	  */
	public dynamic function encode(array : Array<T>):Dynamic {
		return array;
	}

	override public function defaultValue():Array<T> return new Array();

	/**
	  * Load and cache values
	  */
	private function recache():Void {
		arr = decode(super.get());
		altered = false;
	}

/* === Computed Instance Fields === */

	/* the length of [this] Array */
	public var length(get, never):Int;
	private function get_length():Int {
		if (arr == null || altered) {
			recache();
		}
		return arr.length;
	}

/* === Instance Methods === */


	/* whether changes have occurred since we last calculated cached values */
	private var altered : Bool = true;
	private var arr : Null<Array<T>> = null;
}
