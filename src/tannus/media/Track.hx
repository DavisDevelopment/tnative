package tannus.media;

class Track {
	/* Constructor Function */
	public function new(nam:String, loc:String):Void {
		name = nam;
		location = loc;
	}

/* === Instance Fields === */

	/* The Name of [this] Track */
	public var name : String;

	/* The Path or URL to [this] Track */
	public var location : String;
}
