package tannus.io;

import haxe.macro.Expr;

@:callable
abstract Getter<T> (Get<T>) from Get<T> {
	/* Constructor Function */
	public inline function new(f : Get<T>):Void {
		this = f;
	}

/* === Instance Fields === */

	/**
	  * The value [this] references, as a field
	  */
	public var v(get, never):T;
	public inline function get_v():T {
		return this();
	}

/* === Instance Methods === */

	/**
	  * Get the value referenced by [this] Getter
	  */
	@:to
	public inline function get():T {
		return (this());
	}

	/**
	  * Apply a transformation to [this] Getter
	  */
	public function transform<O>(f : T->O):Getter<O> {
		return create(f(get()));
	}

/* === Class Methods === */

	/**
	  * Create a Getter to [val]
	  */
	public static macro function create<T>(val : ExprOf<T>):ExprOf<Getter<T>> {
		return macro new tannus.io.Getter(function() return $val);
	}
}

/* Alias for underlying type */
private typedef Get<T> = Void -> T;
