package tannus.ds;

import tannus.io.Getter;
import tannus.io.Pointer;

import haxe.macro.Expr;
import haxe.macro.Context;

using haxe.macro.ExprTools;
using tannus.macro.MacroTools;

/**
  * Maybe Type = provides tools to make dealing with nullable data easier
  */
@:forward
abstract Maybe<T> (Null<T>) from Null<T> to Null<T> {
	/* Constructor Function */
	public inline function new(x : Null<T>):Void {
		this = x;
	}

	public macro function ternary<A>(self:ExprOf<Maybe<T>>, ify:Expr, ifn:Expr):ExprOf<A> {
		ify = ify.replace(macro _, self);
		return macro ($self.exists ? $ify : $ifn);
	}

	/**
	  * If [this] != null,
	  * @returns [this], otherwise
	  * @returns [alt]
	  */
	@:op(A || B)
	public inline function or(alt : T):T {
		return (this != null ? this : alt);
	}

	/**
	  * [this], or the value returned from [gettr] if [this] is null
	  */
	@:op(A || B)
	public inline function orGetter(gettr : Getter<T>):T {
		return (this != null ? this : gettr);
	}

	/**
	  * 
	  */
	public inline function runIf<A>(f:T->A):Null<A> {
		return (if (exists) f(toNonNullable()) else null);
	}

	/**
	  * Whether [this] Maybe instance is [null], accessed as a field
	  */
	public var exists(get, never):Bool;
	private inline function get_exists():Bool {
		return (this != null);
	}

	/**
	  * [this] cast to <T>, as a field
	  */
	public var value(get, never):T;
	private inline function get_value() return toNonNullable();

	/**
	  * If [this] isn't [null], returns [this], otherwise, throws [error]
	  */
	public inline function orDie(error : Dynamic):T {
		if (!exists) {
			throw error;
		}

		return toNonNullable();
	}

	/**
	  * Under those circumstances where we KNOW that [this]
	  * is not null, we may just cast implicitly
	  */
	@:to
	public inline function toNonNullable():T {
		if (exists) {
			return this;
		} else {
			//throw 'TypeError: Cannot declare NULL non-nullable!';
			return this;
		}
	}

	/**
	  * Allow the use of [this] as a Maybe instance in things like
	  * 'if' statements
	  */
	@:to
	public inline function toBoolean():Bool {
		return (this != null);
	}
}
