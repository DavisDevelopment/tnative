package tannus.media;

import tannus.ds.*;
import tannus.ds.tuples.Tup2;

import Std.*;
import tannus.math.TMath.*;

using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;

class TimeRange implements Comparable<TimeRange> {
	/* Constructor Function */
	public function new(s:Duration, e:Duration):Void {
		start = s;
		end = e;
	}

/* === Instance Methods === */

	/**
	  * Test whether [this] Range is equivalent to [other]
	  */
	public function equals(other : TimeRange):Bool {
		return (start.equals(other.start) && end.equals(other.end));
	}

	/**
	  * Check that [time] is 'between' [start] and [end] ([time.totalSeconds] >= [start.totalSeconds] && [time.totalSeconds] <= [end.totalSeconds])
	  */
	public inline function contains(time : Duration):Bool {
		return (time.toInt().inRange(start.toInt(), end.toInt()));
	}

	public inline function overlapsWith(other : TimeRange):Bool {
		return (
			contains( other.start ) ||
			contains( other.end ) ||
			other.contains( start ) ||
			other.contains( end )
		);
	}

	public inline function toIntRange():IntRange return new IntRange(start.toInt(), end.toInt());
	public inline function toFloatRange():FloatRange return new FloatRange(start.toFloat(), end.toFloat());

	public function toString():String {
		return 'TimeRange(from $start to $end)';
	}

/* === Computed Instance Fields === */

	public var duration(get, never):Duration;
	private inline function get_duration():Duration {
		return Duration.fromFloat(end.toFloat() - start.toFloat());
	}

/* === Instance Fields === */

	public var start : Duration;
	public var end : Duration;
}

abstract OldTimeRange (TimeTuple) from TimeTuple to TimeTuple {
	/* Constructor Function */
	public inline function new(start:Duration, end:Duration):Void {
		this = new TimeTuple(start, end);
	}

/* === Instance Methods === */

	/* compare [this] to [other] */
	@:op(A == B)
	public inline function equals(other : TimeRange):Bool {
		return (start.equals( other.start ) && end.equals( other.end ));
	}

	/**
	  * Check whether the given time falls within [this] Range
	  */
	public inline function contains(time : Duration):Bool {
		return time.toInt().inRange(start.toInt(), end.toInt());
	}

	@:to
	public inline function toIntRange():IntRange return new IntRange(start.toInt(), end.toInt());
	@:to
	public inline function toFloatRange():FloatRange return new FloatRange(start.toFloat(), end.toFloat());

/* === Instance Fields === */

	public var duration(get, never):Duration;
	private inline function get_duration():Duration return (end - start);

	public var start(get, set):Duration;
	private inline function get_start() return this._0;
	private inline function set_start(v) return (this._0 = v);
	
	public var end(get, set):Duration;
	private inline function get_end() return this._1;
	private inline function set_end(v) return (this._1 = v);

	public var startn(get, set):Float;
	private inline function get_startn():Float return start.totalSeconds;
	private inline function set_startn(v : Float):Float return (start = Duration.fromSecondsF( v )).totalSeconds;

	public var endn(get, set):Float;
	private inline function get_endn():Float return end.totalSeconds;
	private inline function set_endn(v : Float):Float return (end = Duration.fromSecondsF( v )).totalSeconds;
}

private typedef TimeTuple = Tup2<Duration, Duration>;
