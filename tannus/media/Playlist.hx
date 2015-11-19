package tannus.media;

import tannus.io.Ptr;
import tannus.io.ByteArray;

import tannus.ds.Maybe;
import tannus.ds.Object;
import tannus.ds.Dict;

import tannus.media.Track;

class Playlist {
	/* Constructor Function */
	public function new():Void {
		title = 'My Playlist';
		creator = 'Ryan Davis';
		annotation = '';
		date = Date.now();

		tracks = new Array();
	}

/* === Instance Methods === */

	/**
	  * Add a new Track to [this] Playlist
	  */
	public function addTrack(track : Track):Track {
		if (track.index > -1) {
			tracks.insert(track.index, track);
		}
		else {
			tracks.push( track );
		}
		updateIndices();
		return track;
	}

	/**
	  * Remove a Track from [this] Playlist
	  */
	public function removeTrack(track : Track):Bool {
		var status:Bool = tracks.remove( track );
		updateIndices();
		return status;
	}

	/**
	  * Update the 'index' fields of all Tracks
	  */
	private function updateIndices():Void {
		for (t in tracks) {
			var i:Int = t.index = tracks.indexOf( t );
		}
	}

	/**
	  * Sort the tracks of [this] Playlist
	  */
	public function sort(pred : Track -> Track -> Int):Void {
		var track_list:Array<Track> = tracks.copy();
		haxe.ds.ArraySort.sort(track_list, pred);
		tracks = track_list;
		updateIndices();
	}

	/**
	  * Get Track by Index
	  */
	public function getTrackByIndex(i : Int):Maybe<Track> {
		return (tracks[ i ]);
		/*
		for (t in tracks) 
			if (t.index == i) return t;
		return null;
		*/
	}

	/**
	  * Get Track by Location
	  */
	public function getTrackByLocation(loc : String):Maybe<Track> {
		for (t in tracks)
			if (t.location == loc) return t;
		return null;
	}

	/**
	  * Get Track by Name
	  */
	public function getTrackByName(name : String):Maybe<Track> {
		for (t in tracks)
			if (t.title == name) 
				return t;
		return null;
	}

	/**
	  * Get Track by 'id'
	  */
	public function getTrackById(id : String):Maybe<Track> {
		for (t in tracks) {
			if (t.id == id) {
				return t;
			}
		}
		return null;
	}

/* === Computed Instance Fields === */

	/* the number of tracks in [this] Playlist */
	public var length(get, never):Int;
	private inline function get_length():Int return tracks.length;

/* === Instance Fields === */

	/* Title of [this] Playlist */
	public var title : String;

	/* Creator of [this] Playlist */
	public var creator : String;

	/* any/all comments on [this] Playlist */
	public var annotation : String;

	/* creation Date */
	public var date : Date;

	/* List of Tracks in [this] Playlist */
	public var tracks : Array<Track>;
}
