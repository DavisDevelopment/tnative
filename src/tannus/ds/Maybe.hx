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
	  * Whether [this] Maybe instance is [null], accessed as a field
	  */
	public var exists(get, never):Bool;
	private inline function get_exists():Bool {
		return (this != null);
	}

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
		if (this != null) {
			return this;
		} else {
			throw 'TypeError: Cannot declare NULL non-nullable!';
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
