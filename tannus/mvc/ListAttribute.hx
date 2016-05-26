package tannus.mvc;

import tannus.mvc.Model;
import tannus.utils.Error;

import Math.*;
import tannus.math.TMath.*;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;
using tannus.macro.MacroTools;

class ListAttribute<T> extends Attribute<Int> {
	/* Constructor Function */
	public function new(model:Model, name:String):Void {
		super(model, name);

		set( 0 );
	}

/* === Instance Methods === */

	/**
	  * get the value stored at [index]
	  */
	public function getItem(index : Int):Null<T> {
		vi( index );
		return kg(ikey( index ));
	}

	/**
	  * store a value under [index]
	  */
	public function setItem(index:Int, value:T):T {
		vi( index );
		return ks(ikey( index ), value);
	}

	/**
	  * delete [index]
	  */
	public function removeItem(index : Int):Void {
		var before = slice(0, index);
		var after = slice(index + 1);
		truncate(length - 1);
		deallockey(ikey( length ));
		var all = before.concat( after );
		for (i in 0...all.length) {
			setItem(i, all[i]);
		}
	}

	/**
	  * delete the first occurrence of [x] in [this] List
	  */
	public function remove(x : T):Bool {
		for (index in 0...length) {
			var item = getItem( index );
			if (item == x) {
				removeItem( index );
				return true;
			}
		}
		return false;
	}

	/**
	  * obtain a shallow copy of the given range
	  */
	public function slice(index:Int, ?end:Int):Array<T> {
		if (end == null) end = length;
		return [for (i in index...end) getItem( i )];
	}

	/**
	  * get the result of concatenating [this] Array with [arr]
	  */
	public function concat(arr : Array<T>):Array<T> return list().concat( arr );

	/**
	  * insert all items of [tail] onto the end of [this]
	  */
	public function append(tail : Array<T>):Void {
		for (x in tail)
			push( x );
	}

	/**
	  * append [item] to [this] Array
	  */
	public function push(item : T):Int {
		var index = length;
		truncate(index + 1);
		setItem(index, item);
		return length;
	}

	/**
	  * prepend [item] to [this] Array
	  */
	public function unshift(item : T):Void {
		var l = list();
		setItem(0, item);
		truncate(length + 1);
		for (i in 1...length) {
			setItem(i, l[i - 1]);
		}
	}

	/**
	  * remove and return the first item in [this] Array
	  */
	public function shift():Null<T> {
		if (length > 0) {
			var first = getItem( 0 );
			var all = slice( 1 );
			truncate(length - 1);
			for (i in 0...all.length)
				setItem(i, all[i]);
			return first;
		} else return null;
	}

	/**
	  * removes and returns the last item in [this] Array
	  */
	public function pop():Null<T> {
		if (length > 0) {
			var last = getItem(length - 1);
			truncate(length - 1);
			return last;
		} else return null;
	}

	/**
	  * returns the index of the first occurrence of [item]
	  */
	public function indexOf(item : T):Int {
		for (index in 0...length) {
			if (getItem( index ) == item) {
				return index;
			}
		}
		return -1;
	}

	public function lastIndexOf(item : T):Int {
		var i:Int = length;
		while (i > 0) {
			if (getItem( --i ) == item) {
				return i;
			}
		}
		trace( i );
		return -1;
	}

	/**
	  * insert the given [item] at the given [index]
	  */
	public function insert(index:Int, item:T):Void {
		if (index < 0) {
			index = (length + index);
			if (index < 0) index = 0;
		}

		if (index >= length) {
			push( item );
			return ;
		}
		else if (index == 0) {
			unshift( item );
			return ;
		}

		var l = length;
		truncate(l + 1);

		var ii:Int = l - 1;
		while (ii >= index) {
			// move the item at the index 'ii' forward by 1
			setItem((ii + 1), getItem( ii-- ));
		}
		setItem(index, item);
	}

	/**
	  * Reverse [this] List in-place
	  */
	public function reverse():Void {
		for (index in 0...floor(length / 2)) {
			var temp = getItem( index );
			setItem(index, getItem(length - index - 1));
			setItem((length - index - 1), temp);
		}
	}
	
	/**
	  * extract [this]'s data entirely into an Array
	  */
	public function list():Array<T> return this.array();
	public function iterator():ListAttributeIter<T> return new ListAttributeIter( this );

	/**
	  * set [length] to a maximum of [mlen]
	  */
	private function truncate(mlen : Int):Void {
		if (length > mlen) {
			for (index in (mlen + 1)...length) {
				deallockey(ikey( index ));
			}
		}
		else if (mlen > length) {
			for (index in length...mlen) {
				allockey(ikey( index ));
			}
		}
		set( mlen );
	}

	/**
	  * calculate and return the String-key for [index]
	  */
	private inline function ikey(index : Int):String return '$name[$index]';

	/**
	  * Validate indices
	  */
	private inline function vi(index : Int):Void {
		if (index >= length || index < 0) {
			throw new Error('IndexOutOfBoundsError: List index $index does not exist');
		}
	}

/* === Computed Instance Fields === */

	public var length(get, never):Int;
	private inline function get_length():Int return get();

/* === Instance Fields === */
}

@:access( tannus.mvc.ListAttribute )
class ListAttributeIter<T> {
	public function new(l : ListAttribute<T>):Void {
		a = l;
		i = 0;
	}

	public inline function hasNext():Bool {
		return (i < a.length);
	}
	public inline function next():T {
		return a.getItem( i++ );
	}

	private var a : ListAttribute<T>;
	private var i : Int;
}
