package tannus.math;

import tannus.ds.Maybe;
import tannus.ds.FloatRange;
import haxe.Int64;
import tannus.io.ByteArray;

import Std.*;
//import Math.*;

import haxe.macro.Expr;
import haxe.macro.Context;

using StringTools;
using tannus.ds.StringUtils;
using haxe.macro.ExprTools;
using tannus.macro.MacroTools;
using StringTools;
using tannus.ds.StringUtils;

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
	public static inline function angleBetween(x1:Float, y1:Float, x2:Float, y2:Float):Float {
		return (toDegrees(Math.atan2(y2 - y1, x2 - x1)));
	}

	/* distance formula */
	public static inline function distance(x1:Float, y1:Float, x2:Float, y2:Float):Float {
		return Math.sqrt(Math.pow(Math.abs(x2 - x1), 2) + Math.pow(Math.abs(y2 - y1), 2));
	}

	/**
	  * Does the shit
	  */
	public static function toFixed<T:Float>(n:T, c:Int=0):String {
		var sn:String = Std.string( n );
		var bd:String = sn.before('.');
		var wn:Int = Std.parseInt( bd );
		var ad:String = '';
		var res:String = (wn + '');
		if (sn.has('.')) {
			ad = sn.after('.');
			var sl = ad.slice(0, c);
			if (ad.length > sl.length) {
				sl = ad.slice(0, c + 1);
				var idec:Int = Std.parseInt( sl );
				idec = Math.round(idec / 10);
				res += ('.' + idec);
			}
			else {
				res += ('.' + sl);
			}
		}
		return res;
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
		return (Math.abs(n - v) <= threshold);
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
	public static inline function clamp<T:Float>(value:T, min:T, max:T):T {
		return (
			if (value < min) min
			else if (value > max) max
			else value
		);
	}

	/* check whether the given number is greater than [min] and less than [max] */
	public static inline function inRange<T:Float>(value:T, min:T, max:T):Bool {
		return (value >= min && value <= max);
	}

	public static inline function sign (value : Float):Int {
		return (value < 0 ? -1 : (value > 0 ? 1 : 0));
	}

	public static inline function applySign<T:Float>(value:T, sign:Int):T {
		return (value * sign);
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
	  * Obtain the sum of all items in [list]
	  */
	public static function sumf<T>(set:Iterable<T>, extractor:T->Float):Float {
		var res:Null<Float> = null;
		for (item in set) {
			res = (res != null ? (res + extractor( item )) : extractor( item ));
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
		var exp = Math.floor(Math.log( af ) / LN2);
		if (exp < -127)
			exp = -127 
		else if( exp > 128 ) 
			exp = 128;
		var sig = (Math.round((af / Math.pow(2, exp) - 1) * 0x800000) & 0x7FFFFF);
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
		return sign*(1.0 + Math.pow(2, -52)*sig) * Math.pow(2, exp);
	}

	/**
	  * Convert a Double to a 64bit integer
	  */
	@:access( haxe.Int64 )
	/*
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
	*/

	/**
	  * Get the largest element in the given Array
	  */
	public static macro function macmax<T>(list:ExprOf<Array<T>>, test:Expr):ExprOf<T> {
		var testf = test.mapUnderscoreTo( 'val' );
		testf = (macro function(val) return $testf);
		return macro tannus.ds.ArrayTools.max($list, $testf);
	}

	/**
	  * Get the largest element in the given Array
	  */
	public static macro function macmaxe<T>(list:ExprOf<Array<T>>, test:Expr):ExprOf<Float> {
		var testf = test.mapUnderscoreToExpr(macro val);
		testf = (macro function(val) return $testf);
		var res = macro tannus.ds.ArrayTools.max($list, $testf);
		var eres = test.mapUnderscoreToExpr( res );
		return macro $eres;
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
	  * get the smallest element in the given Array
	  */
	public static macro function macmine<T>(list:ExprOf<Array<T>>, test:Expr):ExprOf<Float> {
		var testf = test.mapUnderscoreTo( 'v' );
		testf = (macro function(v) return $test);
		return test.mapUnderscoreToExpr(macro tannus.ds.ArrayTools.min($list, $testf));
	}

	/**
	 * macro-licious 'sum'
	 */
	public static macro function macsum<T>(list:ExprOf<Iterable<T>>, ext:Expr):ExprOf<Float> {
		ext = ext.mapUnderscoreToExpr(macro item);
		if (!ext.hasReturn()) {
			ext = macro return $ext;
		}
		var f:ExprOf<T -> Float> = (macro function(item) $ext);
		return macro tannus.math.TMath.sumf($list, $f);
	}

	/**
	  * get the item in [list] that is most similar to [value] when measured by [f]
	  */
	public static function snap<T:Float>(value:T, min:T, step:T, ?max:T):T {
		if (value < min) {
			return min;
		}
		else if (max != null && value > max) {
			return max;
		}
		else {
			var v:T = min;
			while ( true ) {
				if (value <= v) {
					var prev = (v - step);
					if (value >= prev) {
						/* if [value] is closer to the current value than the next one */
						if ((v - value) < (value - prev)) {
							return v;
						}
						else {
							return prev;
						}
					}
				}

				v += step;
			}
		}
	}
	
	/* pretty-print the given float */
	public static function prettify(num:Float, dec:Int=0):String {
		var i:Int = int( num );
		var si:String = string( i );
		trace( si );
		var res:ByteArray = new ByteArray();
		var index:Int = (si.length-1);
		while (index >= 0) {
			var c = si.byteAt( index );
			res.push( c );
			if ((index + 1) % 3 == 0) {
				res.push(','.code);
			}
			index--;
		}
		res.reverse();
		return res.toString();
	}

	/**
	  * Perform chain comparisons
	  */
	public static function compareChain(nums : Iterable<Int>):Int {
		for (n in nums) {
			if (n == 0) {
				continue;
			}
			else {
				return n;
			}
		}
		return 0;
	}

	/**
	  * Perfrom a lambda chain comparison
	  */
	public static function fcompareChain(getters : Iterable<Void->Int>):Int {
		for (get in getters) {
			var n = get();
			if (n == 0) {
				continue;
			}
			else {
				return n;
			}
		}
		return 0;
	}

/* === Standard Library's Math class mixins === */

	public static inline function abs(v : Float):Float return Math.abs( v );
	public static inline function acos(v:Float):Float return Math.acos( v );
	public static inline function asin(v:Float):Float return Math.asin( v );
	public static inline function atan(v:Float):Float return Math.atan( v );
	public static inline function atan2(x:Float,y:Float):Float return Math.atan2(x, y);
	public static inline function ceil(v:Float):Int return Math.ceil( v );
	public static inline function floor(v:Float):Int return Math.floor( v );
	public static inline function cos(v:Float):Float return Math.cos( v );
	public static inline function exp(v:Float):Float return Math.exp( v );
	public static inline function fceil(v:Float):Float return Math.fceil( v );
	public static inline function ffloor(v:Float):Float return Math.ffloor( v );
	//public static inline function floor(v:Float):Float return Math.floor( v );
	public static inline function fround(v:Float):Float return Math.fround( v );
	public static inline function isFinite(v:Float):Bool return Math.isFinite( v );
	public static inline function isNaN(v:Float):Bool return Math.isNaN( v );
	public static inline function log(v:Float):Float return Math.log( v );
	public static inline function pow(v:Float, exp:Float):Float return Math.pow(v, exp);
	public static inline function random():Float return Math.random();
	public static inline function round(v:Float):Int return Math.round( v );
	public static inline function sin(v:Float):Float return Math.sin( v );
	public static inline function sqrt(v:Float):Float return Math.sqrt( v );
	public static inline function tan(v:Float):Float return Math.tan( v );
}
