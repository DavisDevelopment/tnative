package tannus.format.m3u;

import tannus.io.Byte;
import tannus.io.ByteArray;
import tannus.ds.Maybe;

import tannus.media.Playlist;
import tannus.media.Track;

class Writer extends tannus.format.Writer {
	/* Constructor Function */
	public function new(p : Playlist):Void {
		super();
		playlist = p;
	}

/* === Instance Methods === */

	/* Generate Data */
	public function generate():ByteArray {
		buffer = new ByteArray();

		genHeader();
		genTrackList();

		return buffer;
	}

	/* Generate Header */
	private inline function genHeader():Void {
		line('#EXTM3U');
	}

	/* Generate TrackList */
	private inline function genTrackList():Void {
		for (t in playlist.tracks) {
			line('#EXTINF:${t.duration},Artist - ${t.name}');
			line(t.location);
		}
	}

/* === Instance Fields === */

	private var playlist : Playlist;
}
