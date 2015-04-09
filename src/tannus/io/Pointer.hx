package tannus.io;

import haxe.macro.Expr;
import tannus.io.Getter;
import tannus.io.Setter;

import tannus.ds.TwoTuple;

@:generic
abstract Pointer<T> (TwoTuple<Getter<T>, Setter<T>>) {
	/* Constructor Function */
	public inline function new(g:Getter<T>, s:Setter<T>):Void {
		this = new TwoTuple(g, s);
	}

/* === Instance Fields === */

	/**
	  * The 'value' of [this] Pointer as a field
	  */
	public var value(get, set):T;
	private function get_value():T {
		return (this.one());
	}
	private function set_value(nv : T):T {
		return (this.two( nv ));
	}

	/**
	  * The Getter for [this] Pointer
	  */
	public var getter(get, set):Getter<T>;
	private inline function get_getter():Getter<T> {
		return this.one;
	}
	private inline function set_getter(ng : Getter<T>):Getter<T> {
		return (this.one = ng);
	}

	/**
	  * The Setter for [this] Pointer
	  */
	public var setter(get, set):Setter<T>;
	private inline function get_setter():Setter<T> {
		return this.two;
	}
	private inline function set_setter(ns : Setter<T>):Setter<T> {
		return (this.two = ns);
	}

/* === Instance Methods === */

	/**
	  * 'get' the value of [this] Pointer
	  */
	@:to
	public inline function get():T {
		return getter();
	}

	/**
	  * 'set' the value of [this] Pointer
	  */
	@:op(A &= B)
	public inline function set(nv : T):T {
		return setter(nv);
	}

	/**
	  * 'attach' another Pointer to [this] one, such that when a new value is assigned to [this] one,
	  * that change is mirrored onto the attached Pointer
	  */
	@:op(A += B)
	public inline function attach_ptr(other : Pointer<T>):Void {
		var _t = this.two;
		_t.attach(other.setter);
		this.two = _t;
	}

	/**
	  * 'attach' a Setter to [this] Pointer
	  */
	@:op(A += B)
	public inline function attach_setter(str : Setter<T>):Void {
		var _t = this.two;
		_t.attach( str );
		this.two = _t;
	}

/* === Static Methods === */

	/**
	  * Create a Pointer conveniently
	  */
	public static macro function create<T>(ref : ExprOf<T>):ExprOf<Pointer<T>> {
		return macro (new tannus.io.Pointer(tannus.io.Getter.create($ref), tannus.io.Setter.create($ref)));
	}

	/**
	  * Slightly more robust Pointer creation
	  */
	public static macro function dual<T>(gref:ExprOf<T>, sref:ExprOf<T>):ExprOf<Pointer<T>> {
		return macro (new tannus.io.Pointer(tannus.io.Getter.create($gref), tannus.io.Setter.create($sref)));
	}
}
