package tannus.media;

import tannus.ds.ThreeTuple;

using StringTools;
using tannus.ds.StringUtils;

/**
  * Abstract class to represent to duration of some playable media (sound, video, slideshow, etc)
  */
abstract Duration (Dur) {
	/* Constructor Function */
	public inline function new(s:Int=0, m:Int=0, h:Int=0):Void {
		this = {
			'seconds' : s,
			'minutes' : m,
			'hours'   : h
		};
	}

/* === Instance Methods === */

	/**
	  * Convert [this] Duration into a nice, sexy String
	  */
	@:to
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
	  * Obtain the 'sum' of [this] Duration, and another
	  */
	@:op(A + B)
	public inline function add(other : Duration):Duration {
		return new Duration((seconds + other.seconds), (minutes + other.minutes), (hours + other.hours));
	}

/* === Instance Fields === */

	/**
	  * Total Seconds of [this] Duration
	  */
	public var totalSeconds(get, set):Int;
	private inline function get_totalSeconds():Int {
		return ((60 * 60 * hours) + (60 * minutes) + seconds);
	}
	private inline function set_totalSeconds(v : Int):Int {
		var s:Int = v;
		var m:Int = 0;
		var h:Int = 0;
		if (s >= 60) {
			m = Math.round(s / 60);
			s = (s % 60);
		}
		if (m >= 60) {
			h = Math.round(m / 60);
			m = (m % 60);
		}
		seconds = s;
		minutes = m;
		hours = h;
		return totalSeconds;
	}

	/**
	  * Total Minutes of [this] Duration
	  */
	public var totalMinutes(get, never):Float;
	private inline function get_totalMinutes():Float {
		var res:Float = 0;
		//- Hours
		res += (60 * hours);
		//- Minutes
		res += minutes;
		//- Seconds
		res += (seconds / 60.0);
		return res;
	}

	/**
	  * Total Hours
	  */
	public var totalHours(get, never):Float;
	private inline function get_totalHours():Float {
		var res:Float = 0;
		//- Hours
		res += hours;
		//- Minutes
		res += (totalMinutes / 60.0);
		return res;
	}

	/**
	  * Hours of [this] Duration
	  */
	public var hours(get, set):Int;
	private inline function get_hours() return this.hours;
	private inline function set_hours(nh) return (this.hours = nh);

	/**
	  * Minutes of [this] Duration
	  */
	public var minutes(get, set):Int;
	private inline function get_minutes() return this.minutes;
	private inline function set_minutes(nm) return (this.minutes = nm);

	/**
	  * Seconds of [this] Duration
	  */
	public var seconds(get, set):Int;
	private inline function get_seconds() return this.seconds;
	private inline function set_seconds(ns) return (this.seconds = ns);

/* === Static Methods === */

	/**
	  * Cast to Duration from Int
	  */
	@:from
	public static function fromSecondsI(i : Int):Duration {
		var d:Duration = new Duration();
		d.totalSeconds = i;
		return d;
	}

	/**
	  * From Float
	  */
	@:from
	public static function fromSecondsF(i : Float):Duration {
		var d:Duration = new Duration();
		d.totalSeconds = Math.floor( i );
		return d;
	}

	/**
	  * from String
	  */
	@:from
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
}

/**
  * Unerlying Type of Duration
  */
private typedef Dur = {
	var seconds : Int;
	var minutes : Int;
	var hours   : Int;
};
