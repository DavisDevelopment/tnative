package tannus.io;

import haxe.macro.Expr;

using tannus.macro.MacroTools;

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
	  * Convert [this] to a String
	  */
	@:to
	public inline function toString():String {
		return Std.string(this());
	}

	/**
	  * Apply a transformation to [this] Getter
	  */
	public function transform<O>(f : T->O):Getter<O> {
		function trans_get():O {
			return f(get());
		}
		return new Getter( trans_get );
	}

	/**
	  * macro-transform [this] Getter
	  */
	public macro function map<O>(self:ExprOf<Getter<T>>, trans:Expr):ExprOf<Getter<O>> {
		var tfunc:Expr = trans.mapUnderscoreTo('v');
		tfunc = macro (function(v) return $tfunc);
		return (macro $self.transform( $tfunc ));
	}

	/**
	  * Add [this] to the type it returns
	  */
	@:op(A + B)
	@:commutative
	public static inline function addNumber<T:Float>(get:Getter<T>, val:T):T {
		return (get.get() + val);
	}
	@:op(A + B)
	public static inline function addString(get:Getter<String>, val:String):String {
		return (get.get() + val);
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
typedef Get<T> = Void -> T;
