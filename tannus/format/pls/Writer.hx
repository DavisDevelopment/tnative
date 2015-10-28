package tannus.format.pls;

import tannus.io.Byte;
import tannus.io.ByteArray;
import tannus.io.Ptr;
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

	/* Generate data */
	public function generate():ByteArray {
		buffer = new ByteArray();

		genHeader();
		genTrackList();

		return buffer;
	}

	/* Generate the Header Data */
	private inline function genHeader():Void {
		w( '[playlist]' );
		newline();
		w( 'NumberOfEntries=${playlist.tracks.length}' );
		newline();
	}

	/* Generate the TrackList Data */
	private function genTrackList():Void {
		var i:Int = 1;

		for (t in playlist.tracks) {
			w('Title$i= ${t.name}');
			newline();

			w('File$i=${t.location}');
			newline();
			i++;
		}
	}

/* === Instance Fields === */

	private var playlist : Playlist;
}
