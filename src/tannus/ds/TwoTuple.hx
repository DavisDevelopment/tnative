package tannus.ds;

@:generic
abstract TwoTuple<A, B> (T2<A, B>) {
	/* Constructor Function */
	public inline function new(a:A, b:B):Void {
		this = {
			'a' : a,
			'b' : b
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

/* === Implicit Casting === */

	/* Cast to a human-readable String */
	@:to
	public inline function toString():String {
		return ('(' + Std.string(one) + ', ' + Std.string(two) + ')');
	}

	/* Cast to Array<Dynamic> */
	@:to
	public inline function toDynamicArray():Array<Dynamic> {
		var ar:Array<Dynamic> = [one, two];
		return ar;
	}

#if python
	
	/* Cast to python.Tuple2 */
	@:to
	public inline function toPythonTuple():python.Tuple.Tuple2<A, B> {
		return python.Tuple.Tuple2.make(one, two);
	}

	/* Cast from python.Tuple2 */
	@:from
	public static inline function fromPythonTuple<A, B>(pt : python.Tuple.Tuple2<A, B>):TwoTuple<A, B> {
		return new TwoTuple(pt._1, pt._2);
	}
#end
}

private typedef T2<A, B> = {
	a : A,
	b : B
};
