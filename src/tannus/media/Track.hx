package tannus.media;

class Track {
	/* Constructor Function */
	public function new(nam:String, loc:String):Void {
		index = -1;
		duration = -1;
		name = nam;
		location = loc;
	}

/* === Instance Fields === */

	/* The Name of [this] Track */
	public var name : String;

	/* The Track-Number of [this] Track */
	public var index : Int;

	/* The Duration of [this] Track, in Seconds */
	public var duration : Int;

	/* The Path or URL to [this] Track */
	public var location : String;
}