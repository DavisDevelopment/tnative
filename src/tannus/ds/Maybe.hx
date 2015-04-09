package tannus.ds;

import tannus.io.Getter;
import tannus.io.Pointer;

/**
  * Maybe Type = provides tools to make dealing with nullable data easier
  */
abstract Maybe<T> (Null<T>) from Null<T> {
	/* Constructor Function */
	public inline function new(x : Null<T>):Void {
		this = x;
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
	  * Under those circumstances where we KNOW that [this]
	  * is not null, we may just cast implicitly
	  */
	@:to
	public inline function toNonNullable():T {
		if (this != null) {
			return this;
		} else {
			throw 'TypeError: Cannot declare NULL non-nullable!';
		}
	}
}
