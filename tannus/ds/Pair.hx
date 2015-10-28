package tannus.ds;

import tannus.ds.tuples.Tup2;

@:forward
@:generic
abstract Pair<L, R> (CPair<L, R>) {
	/* Constructor Function */
	public inline function new(l:L, r:R):Void {
		this = new CPair(l, r);
	}

/* === Instance Methods === */

	@:to
	public inline function toString():String return this.toString();

	@:to
	public inline function swap():Pair<R, L> return this.swap();

	@:op(A == B)
	public inline function eq(other : Pair<L, R>):Bool return this.equals(other);
}

@:generic
class CPair<L, R> {
	public inline function new(l:L, r:R):Void {
		left = l;
		right = r;
	}

	public inline function equals(other : Pair<L, R>):Bool {
		return (left == other.left && right == other.right);
	}

	public function toString():String {
		return 'Pair($left, $right)';
	}

	public inline function swap():Pair<R, L> {
		return new Pair(right, left);
	}

	public var left:L;
	public var right:R;
}
