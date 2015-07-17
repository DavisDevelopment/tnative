package tannus.ds;

import Std.string in str;

abstract TwoTuple<A, B> (Array<Dynamic>) {
	/* Constructor Function */
	public inline function new(a:A, b:B):Void {
		this = (untyped [a, b]);
	}

/* === Instance Fields === */

	/**
	  * The first item in [this] Tuple
	  */
	public var one(get, set):A;
	private inline function get_one() return cast this[0];
	private inline function set_one(v : A):A {
		return cast (this[0] = v);
	}

	/**
	  * The second item in [this] Tuple
	  */
	public var two(get, set):B;
	private inline function get_two() return cast this[1];
	private inline function set_two(v : B):B {
		return cast (this[1] = v);
	}

/* === Implicit Casting === */

	/**
	  * To human-readable String
	  */
	public inline function toString():String {
		return ('('+str(one)+', '+str(two)+')');
	}

	/**
	  * To Dynamic Array
	  */
	@:to
	public inline function toArray():Array<Dynamic> {
		return this;
	}

	#if python
	/**
	  * To Python Tuple2
	  */
	@:to
	public inline function toPythonTuple():python.Tuple.Tuple2<A, B> {
		return new python.Tuple.Tuple2(this);
	}
	#end
}
