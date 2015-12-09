package tannus.media;

import tannus.ds.Object;
import tannus.ds.Memory;
import tannus.media.Duration;

class Track {
	/* Constructor Function */
	public function new(nam:String, loc:String):Void {
		id = Memory.uniqueIdString('track-');
		index = -1;
		duration = new Duration();
		name = nam;
		location = loc;
		meta = {};
	}

/* === Instance Methods === */


/* === Instance Fields === */

	/* The Name of [this] Track */
	public var name : String;

	/* The Unique ID of [this] Track */
	public var id : String;

	/* The Track-Number of [this] Track */
	public var index : Int;

	/* The Duration of [this] Track, in Seconds */
	public var duration : Duration;

	/* The Path or URL to [this] Track */
	public var location : String;

	/* Metadata associated with [this] Track */
	public var meta : Object;
}