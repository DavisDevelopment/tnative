package tannus.math;

import tannus.math.TMath;

import haxe.macro.Expr;

abstract Percent (Float) from Float to Float {
	/* Constructor Function */
	public inline function new(f : Float):Void {
		this = f;
	}

/* === Instance Fields === */

	/**
	  * 'value' field - acts as an internal reference to [this] as a Float
	  */
	public var value(get, set):Float;
	private inline function get_value() return this;
	private inline function set_value(nv:Float) return (this = nv);

/* === Instance Methods === */

	/**
	  * Add another Percent to [this] one
	  */
	@:op(A + B)
	public inline function plus(other : Percent):Percent {
		return (this + other.value);
	}

	/**
	  * Increment [this] Percent by one
	  */
	@:op(A++)
	public inline function increment():Percent {
		this++;
		return this;
	}

	/**
	  * Decrement [this] Percent by one
	  */
	@:op(A--)
	@:op(--A)
	public inline function decrement():Percent {
		this--;
		return this;
	}

	/**
	  * Get [this] Percent "of" another number
	  */
	public macro function of(p:ExprOf<Percent>, other) {
		return macro ($other * ($p.value / 100));
	}

	public static function percent(what:Float, of:Float):Percent {
		return new Percent((what/of) * 100);
	}

	public inline function toString():String {
		return ('$value%');
	}
}
