package tannus.math;

import tannus.ds.Maybe;

class TMath {
	public static inline var E = 2.718281828459045;
	public static inline var LN2 = 0.6931471805599453;
	public static inline var LN10 = 2.302585092994046;
	public static inline var LOG2E = 1.4426950408889634;
	public static inline var LOG10E = 0.43429448190325176;
	public static inline var PI = 3.141592653589793;
	public static inline var SQRT1_2 = 0.7071067811865476;
	public static inline var SQRT2 = 1.4142135623730951;

	/* Global variable which Tannus uses to approximate Ellipses */
	public static var KAPPA:Float = {(4 * (Math.sqrt(2) - 1) / 3);};

	// Haxe doesn't specify the size of an int or float, in practice it's 32 bits
	/** The lowest integer value in Flash and JS. */
	public static inline var INT_MIN :Int = -2147483648;

	/** The highest integer value in Flash and JS. */
	public static inline var INT_MAX :Int = 2147483647;

	/** The lowest float value in Flash and JS. */
	public static inline var FLOAT_MIN = -1.79769313486231e+308;

	/** The highest float value in Flash and JS. */
	public static inline var FLOAT_MAX = 1.79769313486231e+308;

	/** Converts an angle in degrees to radians. */
	inline public static function toRadians (degrees :Float) :Float
	{
		return degrees * PI/180;
	}

	/** Converts an angle in radians to degrees. */
	inline public static function toDegrees (radians :Float) :Float
	{
		return radians * 180/PI;
	}

	/** Determines and Returns the angle between two points */
	#if !js @:generic #end
	inline public static function angleBetween<T : Float> (x1:T, y1:T, x2:T, y2:T):Float {
		return (toDegrees(Math.atan2(y2 - y1, x2 - x1)));	
	}

	#if !js @:generic #end
	inline public static function max<T:Float> (a :T, b :T) :T
	{
		return (a > b) ? a : b;
	}

	#if !js @:generic #end
	inline public static function min<T:Float> (a :T, b :T) :T
	{
		return (a < b) ? a : b;
	}

	/**
	 * Find and return the highest value in [nums]
	 */
	#if !js @:generic #end
	public static inline function maxr<T:Float> (nums : Iterable<T>):T {
		var m:Null<T> = null;
		for (n in nums) {
			if (m == null)
				m = n;
			m = max(n, m);
		}
		return m;
	}

	/**
	 * Find and return the lowest value in [nums]
	 */
	#if !js @:generic #end
	public static inline function minr<T:Float> (nums : Array<T>):T {
		var m:Null<T> = null;
		for (n in nums) {
			if (m == null)
				m = n;
			m = min(n, m);
		}
		return m;
	}

	/**
	 * Find and return both the lowest, and the highest value in [nums]
	 */
	#if !js @:generic #end
	public static inline function range<T:Float> (nums : Array<T>):tannus.ds.Range<T> {
		var mi:Null<T> = null;
		var ma:Null<T> = null;

		for (n in nums) {
			if (mi == null) 
				mi = n;
			if (ma == null) 
				ma = n;

			mi = min(n, mi);
			ma = max(n, ma);
		}

		return new tannus.ds.Range(mi, ma);
	}

	/** Perform a linear interpolation between two numbers */
	public static inline function lerp<T:Float> (a:T, b:T, x:Float):Float {
		return a + x * (b - a);
	}

	/** Cast from Float to Int */
	public static inline function i(f : Float):Int {
		return (Std.int(f));
	}

	/** Round a float to the nearest [digit] decimal place */
	public static function roundFloat(f:Float, digit:Int):Float {
		var n:Float = Math.pow(10, digit);
		var r:Float = (Math.round(f * n) / n);
		return r;
	}

	#if !js @:generic #end
	public static inline function average <T : Float> (values:Array<T>):Float {
		var sum:Float = 0;
		for (n in values) sum += n;
		return (sum / (values.length));
	}

	#if !js @:generic #end
	public static inline function largest <T> (items:Iterable<T>, predicate:T -> Float):Float {
		var highest:Float = 0;
		for (item in items) {
			highest = max(highest, predicate(item));
		}
		return highest;
	}

	#if !js @:generic #end
	public static inline function smallest <T> (items:Iterable<T>, predicate:T -> Float):Float {
		var lowest:Float = 0;
		for (item in items) {
			lowest = min(lowest, predicate(item));
		}
		return lowest;
	}

	#if !js @:generic #end
	public static function clamp<T:Float> (value :T, min :T, max :T) :T
	{
		return if (value < min) min
			else if (value > max) max
				else value;
	}

	public static function sign (value : Float):Int {
		return if (value < 0) -1
			else if (value > 0) 1
				else 0;
	}

	/**
	 * Obtain the sum of all items in [list]
	 */
	@:generic
	public static function sum<T : Float>(list : Array<T>):T {
		var res:Maybe<T> = null;
		for (item in list) {
			if (!res.exists) {
				res = item;
			} else {
				res = (res.value + item);
			}
		}
		return res;
	}

	/**
	 * Obtain the unbiased sample variance in a dataset
	 */
	public static function sampleVariance(data : Array<Float>):Float {
		var sampleSize:Int = data.length;
		if (sampleSize < 2)
			return 0;
		var mean:Float = average(data);
		return (sum(data.map(function(val : Float) {
			return Math.pow(val - mean, 2);
		})) / (sampleSize - 1));
	}

	/**
	  * Obtain the standard deviation in the dataset
	  */
	public static function standardDeviation(data : Array<Float>):Float {
		return Math.sqrt(sampleVariance( data ));
	}
}
