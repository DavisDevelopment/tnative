package tannus.math;

import tannus.ds.*;

import Std.is;
import Std.int;
import Slambda.fn;
import tannus.math.TMath.*;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;
using tannus.FunctionTools;
using tannus.math.TMath;

class CTime implements IComparable<CTime> {
    /* Constructor Function */
    public function new(sec:Float=0.0, m:Int=0, h:Int=0, d:Int=0):Void {
        days = 0;
        hours = 0;
        minutes = 0;

        totalSeconds = sec;

		inline function add(n: Float) {
		    totalSeconds += n;
		}

		add(60 * m);
		add(60 * 60 * h);
		add(60 * 60 * 24 * d);

        inormalize();
    }

/* === Instance Methods === */

    public inline function clone():Time {
        return new Time(seconds, minutes, hours, days);
    }

    private static function op(operator:Float->Float->Float, x:Time, y:Time):Time {
        return fromSeconds(operator(x.totalSeconds, y.totalSeconds));
    }

    private function iop(operator:Float->Float->Float, x:Time):Time {
        (totalSeconds = operator(totalSeconds, x.totalSeconds));
        return this;
    }

    public function plusTime(x: Time):Time {
        return op(fn(_1 + _2), this, x);
    }

    public function iplusTime(x: Time):Time {
        return iop(fn(_1 + _2), x);
    }

    public function minusTime(x: Time):Time {
        return op(fn(_1 - _2), this, x);
    }

    public function iminusTime(x: Time):Time {
        return iop(fn(_1-_2), x);
    }

    public function multipliedBy(x: Float):Time {
        return fromSeconds(totalSeconds * x);
    }

    public function dividedBy(x: Float):Time {
        return fromSeconds(totalSeconds / x);
    }

    public function lessThanTime(x: Time):Bool {
        return (n < x.n);
    }

    public function greaterThanTime(x: Time):Bool {
        return (n > x.n);
    }

    public inline function equalsTime(x: Time):Bool {
        return (n == x.n);
    }

    /**
      * compare [this] to [other]
      */
    public function compareTo(other: Time):Int {
        return Reflect.compare(totalSeconds, other.totalSeconds);
    }

    /**
      * create and return a normalized version of [this] Time
      */
    public function normalize():Time {
        var allSecs:Float = (totalSeconds * 1.0);
        return new Time( allSecs );
    }

    /**
      * normalize [this] Time in-place
      */
    public function inormalize():Void {
        var allSecs:Float = (totalSeconds * 1.0);
        this.totalSeconds = allSecs;
    }

    /**
	  * Convert [this] Time into a human-readable String
	  */
	public function toString():String {
		var bits:Array<String> = new Array();
		bits.unshift(floor(seconds) + '');
		bits.unshift(minutes + '');
		if (hours > 0)
			bits.unshift(hours + '');
		if (days > 0)
		    bits.unshift(days + '');
		bits = bits.map(function(s : String) {
			if (s.length < 2)
				s = ('0'.times(2 - s.length) + s);
			return s;
		});
		return bits.join(':');
	}

	public function format(tmp: String):String {
	    inline function re<T>(k:String, v:T) {
	        tmp = tmp.replace('%$k', Std.string( v ));
	    }

	    re('s', floor(seconds));
	    re('sf', seconds);
	    re('S', totalSeconds);
	    re('m', minutes);
	    re('M', totalMinutes);
	    re('h', hours);
	    re('H', totalHours);
	    re('d', days);
		//re('D', totalDays);

	    return tmp;
	}

/* === Computed Instance Fields === */

    /**
      * the total number of days in [this] Time
      */

    /**
      * the total number of hours in [this] Time
      */
    public var totalHours(get, never): Float;
    private inline function get_totalHours() {
        return (
            hours + 
            (totalMinutes / 60.0)
        );
    }

    /**
      * the total number of minutes in [this] Time
      */
    public var totalMinutes(get, never): Float;
    private inline function get_totalMinutes() {
        return (
            (60 * hours) +
            minutes +
            (seconds / 60)
        );
    }

    /**
      * the total number of seconds in [this] Time
      */
    public var totalSeconds(get, set): Float;
    private inline function get_totalSeconds() {
		return (
		    (60 * 60 * 24 * days) + 
		    (60 * 60 * hours) + 
		    (60 * minutes) +
		    seconds
		);
    }
    private function set_totalSeconds(v: Float) {
        // days
        var mul:Int = (60 * 60 * 24);
        days = floor(v / mul);
        v -= (days * mul);

        // hours
        mul = int(mul / 24);
		hours = floor(v / mul);
		v -= (hours * mul);

		// minutes
		mul = int(mul / 60);
		minutes = floor(v / mul);

		// seconds
		seconds = (v - (minutes * mul));

		return totalSeconds;
    }

    public var n(get, never):Float;
    private inline function get_n() return totalSeconds;

/* === Instance Fields === */

    public var seconds: Float;
    public var minutes: Int;
    public var hours: Int;
    public var days: Int;
    //public var years: Int;

/* === Static Methods === */

    public static inline function fromSeconds(seconds: Float):Time {
        return new Time( seconds );
    }

    public static inline function fromDate(date: Date):Time {
        return new Time(date.getSeconds(), date.getMinutes(), date.getHours());
    }

    /**
	  * create a Duration from a String
	  */
	public static function fromString(s : String):Time {
		var data:Array<Float> = s.trim().split(':').map( Std.parseFloat );
		trace( data );
		switch( data ) {
			case [s]:
				return new Time( s );

			case [m, s]:
				return new Time(s, int(m));

			case [h, m, s]:
				return new Time(s, int(m), int(h));

            case [d, h, m, s]:
                return new Time(s, int(m), int(h), int(d));

			default:
				throw 'Invalid Time string "$s"';
		}
	}

	public static function fromFloatArray(a: Array<Float>):Time {
	    switch ( a ) {
            case [s]:
                return new Time( s );

            case [s, m]:
                return new Time(s, int(m));

            case [s, m, h]:
				return new Time(s, int(m), int(h));

			case [s, m, h, d]:
                return new Time(s, int(m), int(h), int(d));

            case _:
                throw 'Cannot extract Time from [$a]';
	    }
	}

    /**
      * check whether the given value either is already or can be transformed into a Time instance
      */
	public static function isTime(x: Dynamic):Bool {
	    if (is(x, CTime) || is(x, Float) || is(x, String)) {
	        return true;
	    }
        else if ((x is Array<Float>) && !cast(x,Array<Dynamic>).empty()) {
            return true; 
        }
        return false;
	}

    /**
      * attempt to transform [x] into a Time instance
      */
	public static function fromAny(x: Dynamic):Time {
	    if (is(x, CTime)) {
	        return cast x;
	    }
        else if (is(x, String)) {
            return fromString(cast x);
        }
        else if (is(x, Float)) {
	        return fromSeconds(cast x);
	    }
        else if ((x is Array<Float>)) {
            var a:Array<Dynamic> = cast x;
            if (a.empty()) {
                return new Time();
            }
            else if (a.all(y->(y is Float))) {
                return fromFloatArray(cast a);
            }
        }
        throw 'TypeError: Cannot convert $x into a Time instance';
	}
}
