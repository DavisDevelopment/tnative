package tnative.io;

import haxe.macro.Expr;

/**
  * abstract class meant to roughly emulate a read-only Pointer
  */
@:callable
@:generic
abstract Getter<T> (Void -> T) from Void->T {
	/* Constructor */
	public inline function new(f : Void->T):Void {
		this = f;
	}
	
/* === Instance Fields === */

	/**
	  * The "value" of [this] Getter as a field
	  */
	public var value(get, never):T;
	private inline function get_value():T return this();

/* === Instance Methods === */

	/**
	  * Retrieve the 'value' of [this] Getter
	  */
	public inline function get():T {
		return this();
	}

	/**
	  * "wrap" [this] Getter is another Function
	  */
	public inline function wrap(wrapper : (Void->T)->T):Void {
		var _f = this;
		var w = wrapper.bind( _f );

		this = w;
	}

	/**
	  * Implicitly cast to the underlying Function's return-type
	  */
	@:to
	public function to():T {
		return (this());
	}

/* === Static Methods === */

	/**
	  * Macro to allow creation of Getters in a convenient fashion
	  */
	public static macro function create<T>(ref : ExprOf<T>):ExprOf<Getter<T>> {
		return macro (new tnative.io.Getter(function() return $ref));
	}
}
