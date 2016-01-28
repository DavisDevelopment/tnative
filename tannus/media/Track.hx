package tannus.media;

import tannus.ds.Object;
import tannus.ds.Memory;
import tannus.media.Duration;

class Track {
	/* Constructor Function */
	public function new(nam:String, loc:String):Void {
		id = Memory.allocRandomId( 12 );
		index = -1;
		duration = new Duration();
		title = nam;
		location = loc;
		meta = new Map();
	}

/* === Instance Methods === */

	/**
	  * Dispose of [this] Track
	  */
	public function dispose():Void {
		Memory.freeRandomId( id );
	}

	/**
	  * set the duration of [this] Track
	  */
	private function set_duration(v : Duration):Duration {
		return (duration = v);
	}

/* === Instance Fields === */

	/* The Name of [this] Track */
	public var title : String;

	/* The Unique ID of [this] Track */
	public var id : String;

	/* The Track-Number of [this] Track */
	public var index : Int;

	/* The Duration of [this] Track, in Seconds */
	public var duration(default, set): Duration;

	/* The Path or URL to [this] Track */
	public var location : String;

	/* Metadata associated with [this] Track */
	public var meta : Map<String, Dynamic>;
}
