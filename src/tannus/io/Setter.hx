package tannus.io;

import haxe.macro.Expr;

@:callable
@:generic
abstract Setter<T> (T -> T) from T -> T {
	/* Constructor Function */
	public inline function new(f : T->T):Void {
		this = f;
	}

/* === Instance Fields === */

	/**
	  * The 'value' of [this] Setter as a field
	  */
	public var value(never, set):T;
	private inline function set_value(nv : T):T {
		return (this( nv ));
	}

/* === Instance Methods === */

	/**
	  * Assign a new value at the place in memory [this] Setter references
	  */
	@:op(A &= B)
	public inline function set(nv : T):T {
		return (this( nv ));
	}

	/**
	  * Wrap [this] Setter in a Function
	  */
	@:op(A *= B)
	public inline function wrap(wrapper : T -> (T -> T) -> T):Void {
		var w = wrapper.bind(_, this);
		this = w;
	}

	/**
	  * Attach another Setter to [this] one
	  */
	@:op(A += B)
	public inline function attach(other : Setter<T>):Void {
		wrap(function(v:T, old:T->T):T {
			other( v );
			return old( v );
		});
	}

/* === Static Methods === */

	/**
	  * Create a Setter instance conveniently
	  */
	public static macro function create<T>(ref : ExprOf<T>):ExprOf<Setter<T>> {
		return macro (new tannus.io.Setter(function(v) {
			$ref = v;

			return $ref;
		}));
	}
}
