package tannus.media;

import tannus.io.Ptr;
import tannus.io.ByteArray;

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
	  * Encode [this] Playlist to PLS Format
	  */
	public function encodeAsPLS():ByteArray {
		var w = new tannus.format.pls.Writer( this );
		return w.generate();
	}

	/**
	  * Encode [this] Playlist to M3U Format
	  */
	public function encodeAsM3U():ByteArray {
		var w = new tannus.format.m3u.Writer(this);
		return w.generate();
	}

	/**
	  * Encode [this] Playlist to XSPF
	  */
	public function encodeAsXSPF():ByteArray {
		var w = new tannus.format.xspf.Writer( this );
		return w.write();
	}

	/**
	  * Encode [this] Playlist to WPL
	  */
	public function encodeAsWPL():ByteArray {
		var w = new tannus.format.wpl.Writer( this );
		return w.generate();
	}

	/**
	  * Encode [this] Playlist to JSON
	  */
	public function encodeAsJSON():ByteArray {
		var vids:Array<Dynamic> = new Array();
		for (t in tracks) 
			vids.push({
				'name': t.name,
				'url' : t.location,
				'meta': t.meta
			});
		return haxe.Json.stringify( vids );
	}

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
		t.index = tracks.indexOf(t);

		return t;
	}

	/**
	  * Remove a Track from [this] Playlist
	  */
	public function removeTrack(track : Track):Bool {
		return tracks.remove( track );
	}

	/**
	  * Get Track by either index or location
	  */
	public function getTrack(q : TrackQ):Maybe<Track> {
		switch (q) {
			case QIndex( i ):
				return trackByIndex(i);

			case QLocation( loc ):
				return (trackByLocation(loc) || trackByName(loc));
		}
	}

	/**
	  * Get Track by Index
	  */
	private function trackByIndex(i : Int):Maybe<Track> {
		for (t in tracks) 
			if (t.index == i) return t;
		return null;
	}

	/**
	  * Get Track by Location
	  */
	private function trackByLocation(loc : String):Maybe<Track> {
		for (t in tracks)
			if (t.location == loc) return t;
		return null;
	}

	/**
	  * Get Track by Name
	  */
	private function trackByName(name : String):Maybe<Track> {
		for (t in tracks)
			if (t.name == name) return t;
		return null;
	}

/* === Instance Fields === */

	/* Title of [this] Playlist */
	public var title : String;

	/* List of Tracks in [this] Playlist */
	public var tracks : Array<Track>;
}

/**
  * Type-Safe Wrapper thing
  */
private abstract TrackQ (ETrackQ) from ETrackQ to ETrackQ {
	public inline function new(q : ETrackQ) this = q;

	@:from
	public static inline function fromString(s : String):TrackQ {
		return QLocation(s);
	}

	@:from
	public static inline function fromInt(i : Int):TrackQ {
		return QIndex(i);
	}
}

/**
  * Enum of different ways Tracks can be queried
  */
private enum ETrackQ {
	QIndex(i : Int);
	QLocation(loc : String);
}
