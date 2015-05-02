package tannus.media;

import tannus.io.Ptr;
import tannus.ds.Maybe;
import tannus.ds.Object;

import tannus.media.Track;

class Playlist {
	/* Constructor Function */
	public function new():Void {
		title = 'My Playlist';
		tracks = new Array();
	}

/* === Instance Methods === */

	/**
	  * Add a new Track to [this] Playlist
	  */
	public function addTrack(name:String, location:String, ?trackn:Maybe<Int>):Track {
		var t:Track = new Track(name, location);

		if (trackn) {
			tracks.insert(trackn, t);
		} else {
			tracks.push( t );
		}

		return t;
	}

/* === Instance Fields === */

	/* Title of [this] Playlist */
	public var title : String;

	/* List of Tracks in [this] Playlist */
	public var tracks : Array<Track>;
}
