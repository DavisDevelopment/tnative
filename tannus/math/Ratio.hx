package tannus.math;

import tannus.math.Percent;

@:forward
abstract Ratio (CRatio) from CRatio to CRatio {
	/* Constructor Function */
	public inline function new(top:Float, bottom:Float):Void {
		this = new CRatio(top, bottom);
	}

/* === Instance Methods === */

	@:op(A == B)
	public inline function equals(other : Ratio):Bool return this.equals( other );

	@:to
	public inline function toFloat():Float return this.toFloat();
	@:to
	public inline function toString():String return this.toString();
	@:to
	public inline function toPercent():Percent return this.toPercent();

	@:from
	public static inline function fromFloatArray(a : Array<Float>):Ratio {
		return new Ratio(a[0], a[1]);
	}

	@:from
	public static inline function fromIntArray(a : Array<Int>):Ratio {
		return new Ratio(a[0], a[1]);
	}
}

class CRatio {
	/* Constructor Function */
	public function new(t:Float, b:Float):Void {
		top = t;
		bottom = b;
	}

/* === Instance Methods === */

	/* get the value of [bottom] when [top] = [topValue] */
	public inline function bottomValue(topValue : Float):Float {
		return ((topValue / top) * bottom);
	}

	/* get the value of [top] when [bottom]=[bottomValue] */
	public inline function topValue(bottomValue : Float):Float {
		return ((bottomValue / bottom) * top);
	}

	/**
	  * get the float-value of [this] Ratio
	  */
	public function toFloat():Float {
		return (top / bottom);
	}

	/**
	  * convert [this] to a String
	  */
	public function toString():String {
		return '$top / $bottom';
	}

	/**
	  * convert [this] to a Percent
	  */
	public function toPercent():Percent {
		return Percent.percent(top, bottom);
	}

	/**
	  * check whether [this] is equal to [other]
	  */
	public function equals(other : Ratio):Bool {
		return (toFloat() == other.toFloat());
	}

	/* the reciprocal of [this] ratio */
	public inline function reciprocal():Ratio {
		return new Ratio(1, toFloat());
	}

/* === Computed Instance Fields === */

	/* [this] as a Percent */
	public var percent(get, never):Percent;
	private inline function get_percent():Percent return toPercent();

/* === Instance Fields === */

	public var top : Float;
	public var bottom : Float;
}
