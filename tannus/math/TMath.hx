package tannus.math;

import tannus.ds.Maybe;
import tannus.ds.FloatRange;
import haxe.Int64;

import Math.*;

import haxe.macro.Expr;
import haxe.macro.Context;

using haxe.macro.ExprTools;
using tannus.macro.MacroTools;

@:expose('TMath')
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
	public static function angleBetween(x1:Float, y1:Float, x2:Float, y2:Float):Float {
		var degs:Float = (toDegrees(Math.atan2(y2 - y1, x2 - x1)));	
		while (degs < 0) {
			degs = (360 - Math.abs(degs));
		}
		return degs;
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

	/**
	  * Check whether [n] is "almost" equal to [v]
	  */
	public static inline function almostEquals<T:Float>(n:T, v:T, threshold:T):Bool {
		return (abs(n - v) <= threshold);
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
	public static function largest<T>(items:Iterable<T>, predicate:T -> Float):Float {
		var highest:Float = 0;
		for (item in items) {
			highest = max(highest, predicate(item));
		}
		return highest;
	}

	#if !js @:generic #end
	public static function smallest<T>(items:Iterable<T>, predicate:T -> Float):Float {
		var lowest:Float = 0;
		for (item in items) {
			lowest = min(lowest, predicate(item));
		}
		return lowest;
	}

	/**
	  * using [predicate] to 'score' each value in [items], return the value which scored the highest
	  */
	public static function largestItem<T>(items:Iterable<T>, predicate:T->Float):Null<T> {
		var asarr = Lambda.array(items);
		if (asarr.length == 0)
			return null;
		else if (asarr.length == 1)
			return asarr[0];
		else if (asarr.length == 2) {
			var px = predicate(asarr[0]);
			var py = predicate(asarr[1]);
			if (px >= py)
				return asarr[0];
			else 
				return asarr[1];
		}
		else {
			var best:Null<{item:T, score:Float}> = null;
			for (item in items) {
				var score = predicate( item );
				if (best == null || score > best.score) {
					best = {
						'item' : item,
						'score': score
					};
				}
			}
			return best.item;
		}
	}

	#if !js @:generic #end
	public static function minmax<T>(items:Iterable<T>, predicate:T->Float):FloatRange {
		var res:FloatRange = new FloatRange(Math.NaN, Math.NaN);
		for (item in items) {
			var score = predicate(item);
			if (res.max < score || Math.isNaN(res.max)) {
				res.max = score;
			}
			else if (res.min > score || Math.isNaN(res.min)) {
				res.min = score;
			}
			if (res.min > res.max) {
				var _t = res.max;
				res.max = res.min;
				res.min = _t;
			}
		}
		return res;
	}

	@:generic
	public static inline function clamp<T:Float> (value :T, min :T, max :T) :T
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

	/**
	  * Convert 32bit integer to a floating-point value
	  */
	public static function i32ToFloat(i : Int):Float {
		var sign = (1 - ((i >>> 31) << 1));
		var exp = ((i >>> 23) & 0xFF);
		var sig = (i & 0x7FFFFF);
		if( sig == 0 && exp == 0 )
			return 0.0;
		return (sign * (1 + Math.pow(2, -23)*sig) * Math.pow(2, (exp - 127)));
	}

	/**
	  * Convert a floating-point value to a 32bit integer
	  */
	public static function floatToI32(f : Float):Int {
		if(f == 0)
			return 0;
		var af = (f < 0 ? -f : f);
		var exp = floor(log( af ) / LN2);
		if (exp < -127)
			exp = -127 
		else if( exp > 128 ) 
			exp = 128;
		var sig = (round((af / pow(2, exp) - 1) * 0x800000) & 0x7FFFFF);
		return ((f < 0 ? 0x80000000 : 0) | ((exp + 127) << 23) | sig);
	}

	/**
	  * Convert a 64bit integer to a Double
	  */
	public static function i64ToDouble(low:Int, high:Int):Float {
		var sign = 1 - ((high >>> 31) << 1);
		var exp = ((high >> 20) & 0x7FF) - 1023;
		var sig = (high&0xFFFFF) * 4294967296. + (low>>>31) * 2147483648. + (low&0x7FFFFFFF);
		if( sig == 0 && exp == -1023 )
			return 0.0;
		return sign*(1.0 + pow(2, -52)*sig) * pow(2, exp);
	}

	/**
	  * Convert a Double to a 64bit integer
	  */
	@:access( haxe.Int64 )
	public static function doubleToI64(v : Float):Int64 {
		var i64:Int64 = Int64.ofInt( 0 );
		if( v == 0 ) {
			i64.set_low(0);
			i64.set_high(0);
		}
		else {
			var av = (v < 0 ? -v : v);
			var exp = floor(log( av ) / LN2);
			var sig = fround(((av / pow(2, exp)) - 1) * 4503599627370496.);
			var sig_l = Std.int( sig );
			var sig_h = Std.int(sig / 4294967296.0);
			i64.set_low( sig_l );
			i64.set_high((v < 0 ? 0x80000000 : 0) | ((exp + 1023) << 20) | sig_h);
		}
		return i64;
	}

	/**
	  * Get the largest element in the given Array
	  */
	public static macro function macmax<T>(list:ExprOf<Array<T>>, test:Expr):ExprOf<T> {
		test = test.mapUnderscoreTo( 'val' );
		test = (macro function(val) return $test);
		return macro tannus.ds.ArrayTools.max($list, $test);
	}

	/**
	  * get the smallest element in the given Array
	  */
	public static macro function macmin<T>(list:ExprOf<Array<T>>, test:Expr):ExprOf<T> {
		test = test.mapUnderscoreTo( 'v' );
		test = (macro function(v) return $test);
		return macro tannus.ds.ArrayTools.min($list, $test);
	}

	/**
	 * macro-licious 'sum'
	 */
	public static macro function macsum<T>(list:ExprOf<Array<T>>, ext:Expr):ExprOf<Float> {
		ext = ext.mapUnderscoreTo('v');
		var f:ExprOf<T -> Float> = (macro function(v) return $ext);
		return macro (function() {
			var res:Float = 0;
			var extract = $f;
			for (value in $list) {
				res += extract( value );
			}
			return res;
		}());
	}
}
