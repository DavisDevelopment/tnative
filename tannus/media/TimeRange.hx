package tannus.media;

import tannus.ds.*;
import tannus.ds.tuples.Tup2;

import Std.*;
import tannus.math.TMath.*;

using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;

class TimeRange implements Comparable<TimeRange> implements IComparable<TimeRange> {
	/* Constructor Function */
	public function new(start:Float, end:Float):Void {
	    this.start = start;
	    this.end = end;
	}

/* === Instance Methods === */

	/**
	  * Test whether [this] Range is equivalent to [other]
	  */
	public function equals(other : TimeRange):Bool {
	    return (start == other.start && end == other.end);
	}

	/**
	  * compare [this] to [other]
	  */
	public function compareTo(other : TimeRange):Int {
	    var d = Reflect.compare(start, other.start);
	    if (d != 0) {
	        return d;
	    }
        d = Reflect.compare(end, other.end);
        return d;
	}

	/**
	  * Check that [time] is 'between' [start] and [end] ([time.totalSeconds] >= [start.totalSeconds] && [time.totalSeconds] <= [end.totalSeconds])
	  */
	public inline function contains(time : Float):Bool {
	    return time.inRange(start, end);
	}

    /**
      * check whether [this] and [other] overlap
      */
	public inline function overlapsWith(other : TimeRange):Bool {
		return (
			contains( other.start ) ||
			contains( other.end ) ||
			other.contains( start ) ||
			other.contains( end )
		);
	}

	/**
	  * get the sum of [this] TimeRange and [other]
	  */
	public function plus(other : TimeRange):TimeRange {
	    return new TimeRange(min(start, other.start), max(end, other.end));
	}

	/**
	  * divide [this] TimeRange into [n] pieces
	  */
	public function divide(n : Int):Array<TimeRange> {
	    var s = start;
	    var result = [];
	    var len = (length / n);
	    for (i in 0...n) {
	        var tr = new TimeRange(s, (s + len));
	        result.push( tr );
	        s += len;
	    }
	    return result;
	}

	/**
	  * split [this] TimeRange into pieces of at most [len] length
	  */
	public function split(len : Float):Array<TimeRange> {
	    var rem:Float = length;
	    var res:Array<TimeRange> = new Array();
	    var s = start;
	    while (rem > 0) {
	        var l = min(rem, len);
	        var tr = new TimeRange(s, (s + l));
	        s += l;
	        rem -= l;
	        res.push( tr );
	    }
	    return res;
	}

    /**
      * convert [this] to an IntRange
      */
	public function toIntRange(?i : Float->Int):IntRange {
	    if (i == null)
	        i = Std.int;
	    return new IntRange(i(start), i(end));
    }

	/**
	  * convert [this] to a FloatRange
	  */
	public inline function toFloatRange():FloatRange return new FloatRange(start, end);

    /**
      * convert [this] to a String
      */
	public function toString():String {
		return 'TimeRange(from $start to $end)';
	}

/* === Computed Instance Fields === */

	public var duration(get, never):Duration;
	private inline function get_duration() return Duration.fromFloat( length );

	public var length(get, never):Float;
	private inline function get_length() return (end - start);

/* === Instance Fields === */

	public var start : Float;
	public var end : Float;
}
