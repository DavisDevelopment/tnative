package tannus.media;

import tannus.ds.*;
import tannus.ds.tuples.Tup2;

#if js
import js.html.TimeRanges in Ntr;
#end

import Std.*;
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
	public function getTotal():Float {
	    return this.macsum( _.length );
	}

	/* find and return the first range in [this] that 'contains' [time] */
	public function findContainingRange(time : Float):Null<TimeRange> {
		return this.macfirstMatch(_.contains( time ));
	}

	/* check whether any range in [this] contains [time] */
	public function inAnyRange(time : Float):Bool {
		return (findContainingRange( time ) != null);
	}

	/* sort the ranges into numerical order */
	public function sortRanges():Void {
	    this.sort(function(x, y) {
	        return x.compareTo( y );
	    });
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
