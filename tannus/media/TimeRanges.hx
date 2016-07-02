package tannus.media;

import tannus.ds.*;
import tannus.ds.tuples.Tup2;

#if js
import js.html.TimeRanges in Ntr;
#end

import Std.*;
import Math.*;
import tannus.math.TMath.*;

using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;

@:forward
abstract TimeRanges (Array<TimeRange>) from Array<TimeRange> to Array<TimeRange> {
	/* Constructor Function */
	public inline function new(a : Array<TimeRange>):Void {
		this = a;
	}

/* === Instance Methods === */

	/* the total duration of all ranges */
	public inline function getTotal():Duration {
		return Duration.fromSecondsF(this.macsum(_.duration.toFloat()));
	}

	/* find and return the first range in [this] that 'contains' [time] */
	public inline function findContainingRange(time : Duration):Null<TimeRange> {
		return this.macfirstMatch(_.contains( time ));
	}

	/* check whether any range in [this] contains [time] */
	public inline function inAnyRange(time : Duration):Bool {
		return (findContainingRange( time ) != null);
	}

	/* sort the ranges into numerical order */
	public function sortRanges():Void {
		this.macsort(y.start.toInt() - x.start.toInt());
	}

#if js

	/**
	  * Create and return from a native TimeRanges object
	  */
	@:from
	public static function fromJavaScriptTimeRanges(trl : Ntr):TimeRanges {
		var ranges:TimeRanges = new TimeRanges([]);
		for (index in 0...trl.length) {
			var range = new TimeRange(trl.start( index ), trl.end( index ));
			ranges.push( range );
		}
		return ranges;
	}

#end
}
