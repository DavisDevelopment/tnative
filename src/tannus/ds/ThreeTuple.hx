package tannus.ds;

@:generic
abstract ThreeTuple<A, B, C> (T3<A, B, C>) {
	/* Constructor Function */
	public inline function new(a:A, b:B, c:C):Void {
		this = {
			'a' : a,
			'b' : b,
			'c' : c
		};
	}

/* === Instance Fields === */

	/**
	  * The First Element of [this] Tuple
	  */
	public var one(get, set):A;
	private inline function get_one():A return this.a;
	private inline function set_one(v : A):A return (this.a = v);

	/**
	  * The Second Element of [this] Tuple
	  */
	public var two(get, set):B;
	private inline function get_two():B return this.b;
	private inline function set_two(v:B):B return (this.b = v);

	/**
	  * The Third Element of [this] Tuple
	  */
	public var three(get, set):C;
	private inline function get_three():C return this.c;
	private inline function set_three(v : C):C return (this.c = v);

	/**
	  * Cast to a human-readable String
	  */
	@:to
	public inline function toString():String {
		return ('(' + Std.string(one) + ', ' + Std.string(two) + ', ' + Std.string(three)')');
	}
}

private typedef T3<A, B, C> = {
	a : A,
	b : B,
	c : C
};
