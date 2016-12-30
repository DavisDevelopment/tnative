package tannus.ds.data;

import haxe.ds.Vector;

class Data<T> implements IData<T> {
	/* Constructor Function */
	public function new(len:Int, ?value:T):Void {
		size = [len, 0];
		d = new Vector( capacity );
		fill( value );
	}

/* === Instance Methods === */

	public inline function get(index : Int):Null<T> {
		return d.get( index );
	}
	public function set(index:Int, value:Null<T>):Null<T> {
		var delta:Int = 0;
		if (value != null && !has( index )) {
			delta = 1;
		}
		else if (value == null && has( index )) {
			delta = -1;
		}
		d.set(index, value);
		size[1] += delta;
		return get( index );
	}
	public inline function has(index : Int):Bool {
		return (get(index) != null);
	}
	public function add(value : T):Int {
		var index:Int = 0;
		while (index < capacity) {
			if (!has(index)) {
				set(index, value);
				return index;
			}
			index++;
		}
		return -1;
	}
	public inline function fill(value : T):Void {
		for (i in 0...capacity) {
			set(i, value);
		}
	}
	public function sets(values : Array<T>):Void {
		for (i in 0...values.length) {
			set(i, values[i]);
		}
	}

	private function reset(impl : Vector<T>):Data<T> {
		d = impl;
		size = [d.length, 0];
		for (i in 0...d.length) {
			if (has( i )) {
				size[1]++;
			}
		}
		return this;
	}

/* === Computed Instance Fields === */

	// total slots in [this] DataView
	public var capacity(get, never):Int;
	private inline function get_capacity():Int return size[0];

	// number of available slots
	public var length(get, never):Int;
	private inline function get_length():Int return size[1];

	public var full(get, never):Bool;
	private inline function get_full():Bool {
		return (length == capacity);
	}

/* === Instance Fields === */

	private var size : Array<Int>;
	private var d : Vector<T>;

/* === Static Factory Methods === */

	public static inline function fromDataImpl<T>(impl : Vector<T>):Data<T> {
		return new Data(0).reset( impl );
	}

	public static inline function fromArray<T>(array : Array<T>):Data<T> {
		return fromDataImpl(Vector.fromArrayCopy( array ));
	}
}
