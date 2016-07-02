package tannus.media;

import tannus.ds.ThreeTuple;
import Math.*;
import tannus.math.TMath.*;
import tannus.ds.Comparable;

using StringTools;
using tannus.ds.StringUtils;
using tannus.math.TMath;

@:forward
abstract Duration (CDur) from CDur to CDur {
	/* Constructor Function */
	public function new(s:Int=0, m:Int=0, h:Int=0):Void {
		this = new CDur(s, m, h);
	}

	@:op(A == B)
	public inline function equals(other : Duration):Bool return this.equals( other );
	@:op(A != B)
	public inline function nequals(other : Duration):Bool return !equals( other );
	@:op(A > B)
	public inline function gt(other : Duration):Bool return this.greaterThan( other );
	@:op(A < B)
	public inline function lt(other : Duration):Bool return this.lessThan( other );

	@:op(A + B)
	public inline function plus(other : Duration):Duration return this.plus( other );
	@:op(A - B)
	public inline function minus(other : Duration):Duration return this.minus( other );

	/**
	  * Cast [this] to a String
	  */
	@:to
	public inline function toString():String {
		return this.toString();
	}
	
	/**
	  * Cast [this] to an Int
	  */
	@:to
	public inline function toInt():Int {
		return this.totalSeconds;
	}

	/**
	  * cast [this] to a Float
	  */
	@:to
	public inline function toFloat():Float {
		return (this.totalSeconds + 0.0);
	}

	@:from
	public static inline function fromSecondsI(i : Int):Duration return CDur.fromSecondsI( i );
	@:from
	public static inline function fromSecondsF(n : Float):Duration return CDur.fromSecondsF( n );
	@:from
	public static inline function fromInt(i : Int):Duration return CDur.fromInt( i );
	@:from
	public static inline function fromFloat(n : Float):Duration return CDur.fromFloat( n );
	@:from
	public static inline function fromString(s : String):Duration return CDur.fromString( s );
	@:from
	public static inline function fromIntArray(a : Array<Int>):Duration return CDur.fromIntArray( a );
}

@:expose( 'tannus.media.Duration' )
class CDur implements Comparable<CDur> {
	/* Constructor Function */
	public function new(s:Int, m:Int, h:Int):Void {
		seconds = s;
		minutes = m;
		hours = h;
	}

/* === Instance Methods === */

	/**
	  * Convert [this] Duration into a human-readable String
	  */
	public function toString():String {
		var bits:Array<String> = new Array();
		bits.unshift(seconds+'');
		bits.unshift(minutes+'');
		if (hours > 0)
			bits.unshift(hours+'');
		bits = bits.map(function(s : String) {
			if (s.length < 2)
				s = ('0'.times(2 - s.length) + s);
			return s;
		});
		return bits.join(':');
	}

	/**
	  * check for equality between [this] and [other]
	  */
	public function equals(other : CDur):Bool {
		return (seconds == other.seconds && minutes == other.minutes && hours == other.hours);
	}

	/**
	  * test whether [this] is 'greater than' [other]
	  */
	public inline function greaterThan(other : Duration):Bool {
		return (toInt() > other.toInt());
	}

	/**
	  * test whether [this] is 'less than' [other]
	  */
	public inline function lessThan(other : Duration):Bool {
		return (toInt() < other.toInt());
	}

	/**
	  * compare [this] with [other]
	  */
	public function compare(other : Duration):Int {
		return (
			if (equals( other )) 0
			else if (greaterThan( other )) 1
			else -1
		);
	}

	/**
	  * get the sum of [this] and [other]
	  */
	public function plus(other : Duration):Duration {
		return fromSecondsI(totalSeconds + other.totalSeconds);
	}

	/**
	  * get the difference between [this] and [other]
	  */
	public function minus(other : Duration):Duration {
		return fromInt(toInt() - other.toInt());
	}

	/**
	  * Convert [this] to an Int
	  */
	public inline function toInt():Int return totalSeconds;

	/**
	  * Convert [this] to a Float
	  */
	public inline function toFloat():Float return (toInt() + 0.0);

/* === Computed Instance Fields === */

	public var totalHours(get, never):Int;
	private inline function get_totalHours():Int {
		return floor(hours + (minutes / 60.0));
	}

	public var totalMinutes(get, never):Int;
	private inline function get_totalMinutes():Int {
		return floor((60 * hours) + minutes + (seconds / 60.0));
	}

	public var totalSeconds(get, set):Int;
	private inline function get_totalSeconds():Int {
		return ((60 * 60 * hours) + (60 * minutes) + seconds);
	}
	private function set_totalSeconds(v : Int):Int {
		hours = floor(v / 3600);
		v = (v - hours * 3600);
		minutes = floor(v / 60);
		seconds = (v - minutes * 60);
		return totalSeconds;
	}

/* === Instance Fields === */

	public var seconds : Int;
	public var minutes : Int;
	public var hours : Int;

/* === Static Methods === */

	/**
	  * create a Duration from an Int
	  */
	public static function fromSecondsI(i : Int):Duration {
		var d = new Duration();
		d.totalSeconds = i;
		return d;
	}
	public static inline function fromInt(i : Int):Duration return fromSecondsI( i );

	/**
	  * create a Duration from a Float
	  */
	public static inline function fromSecondsF(n : Float):Duration {
		return fromSecondsI(floor( n ));
	}
	public static inline function fromFloat(n : Float):Duration return fromSecondsF( n );

	/**
	  * create a Duration from a String
	  */
	public static function fromString(s : String):Duration {
		var data = s.trim().split(':').map( Std.parseInt );
		switch( data ) {
			case [s]:
				return new Duration( s );
			case [m, s]:
				return new Duration(s, m);
			case [h, m, s]:
				return new Duration(s, m, h);
			default:
				throw 'Invalid Duration string "$s"';
		}
	}

	/**
	  * create a Duration from an Array<Int>
	  */
	public static inline function fromIntArray(a : Array<Int>):Duration {
		return new Duration(a[0], a[1], a[2]);
	}
}

/**
  * Unerlying Type of Duration
  */
private typedef Dur = {
	var seconds : Int;
	var minutes : Int;
	var hours   : Int;
};
