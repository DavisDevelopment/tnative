package tannus.media;

import tannus.ds.ThreeTuple;

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

	public function toString():String {
		var bits:Array<String> = new Array();
		if (hours > 0) {
			bits.push('${hours}hr');
		}
		if (minutes > 0)
			bits.push('${minutes}min');
		if (seconds > 0)
			bits.push('${seconds}sec');
		return bits.join(' ');
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
}

/**
  * Unerlying Type of Duration
  */
private typedef Dur = {
	var seconds : Int;
	var minutes : Int;
	var hours   : Int;
};