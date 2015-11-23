package tannus.math;

import tannus.math.TMath;

import haxe.macro.Expr;

@:forward
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

	/* [this] as a Float, not a Percent */
	public var delta(get, set):Float;
	private inline function get_delta():Float return (this / 100);
	private inline function set_delta(v : Float):Float return (this = (v * 100));

/* === Instance Methods === */

	/* convert to Float */
	@:to
	public inline function toDelta():Float {
		return delta;
	}

	/**
	  * The complement (or inverse) of [this] Percent
	  */
	@:op( !A )
	public inline function complement():Percent {
		return (100 - this);
	}

	/**
	  * Add another Percent to [this] one
	  */
	@:op(A + B)
	public inline function plus(other : Percent):Percent {
		return (this + other.value);
	}

	/**
	  * Get the difference between [this] Percent and some other one
	  */
	@:op(A - B)
	public inline function minus(other : Percent):Percent {
		return (this - other.value);
	}

	/**
	  * Increment [this] Percent by one
	  */
	@:op(++A)
	public inline function preincrement():Percent {
		return ++this;
	}

	/**
	  * Increment [this] Percent by one
	  */
	@:op(A++)
	public inline function postincrement():Percent {
		return this++;
	}

	/**
	  * Decrement [this] Percent by one
	  */
	@:op(--A)
	public inline function decrement():Percent {
		return --this;
	}

	/**
	  * Get [this] Percent "of" another number
	  */
	public macro function of(p:ExprOf<Percent>, other:ExprOf<Float>):ExprOf<Float> {
		return macro ($other * ($p.value / 100));
	}

	/**
	  * Calculate a Percent from the relationship between [what] and [of]
	  */
	public static function percent(what:Float, of:Float):Percent {
		return new Percent((what/of) * 100);
	}

	/**
	  * Convert [this] Percent to a human-readable String
	  */
	@:to
	public inline function toString():String {
		return ('$value%');
	}
}
