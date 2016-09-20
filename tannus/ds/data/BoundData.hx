package tannus.ds.data;

import haxe.ds.Vector;
import tannus.io.Ptr;

class BoundData<T> implements IData<T> {
	/* Constructor Function */
	public function new(refs : Array<Ptr<T>>):Void {
		d = Vector.fromArrayCopy( refs );
		size = [d.length, d.length];
	}

/* === Instance Methods === */

	public inline function get(index : Int):Null<T> {
		return d.get( index ).get();
	}
	public inline function set(index:Int, value:Null<T>):Null<T> {
		return d.get( index ).set( value );
	}
	public inline function has(index:Int):Bool {
		return (get( index ) != null);
	}
	public function add(value : T):Int {
		for (i in 0...capacity) {
			if (!has( i )) {
				set(i, value);
				return i;
			}
		}
		return -1;
	}
	public function fill(value : T):Void {
		for (i in 0...capacity) {
			set(i, value);
		}
	}
	public function sets(values : Array<T>):Void {
		for (i in 0...values.length) {
			set(i, values[i]);
		}
	}

/* === Computed Instance Fields === */

	public var capacity(get, never):Int;
	private inline function get_capacity():Int return size[0];
	public var length(get, never):Int;
	private inline function get_length():Int return size[1];
	public var full(get, never):Bool;
	private inline function get_full():Bool return (length == capacity);

/* === Instance Fields === */

	private var size : Array<Int>;
	private var d : Vector<Ptr<Null<T>>>;
}
