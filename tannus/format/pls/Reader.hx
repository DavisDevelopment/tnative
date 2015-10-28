package tannus.format.pls;

import tannus.io.ByteArray;
import tannus.media.Playlist;
import tannus.media.Track;

using StringTools;
class Reader {
	/* Constructor Function */
	public function new():Void {
		reset();
	}

/* === Instance Methods === */

	/**
	  * Restore [this] instance to it's default state
	  */
	private inline function reset():Void {
		playlist = new Playlist();
	}

	/**
	  * Read the Playlist from a ByteArray
	  */
	public function read(data : ByteArray):Array<Track> {
		var content:String = data.toString();
		var lines:Array<String> = content.split('\n');
		lines.shift();
		var num:Int = Std.parseInt(lines.shift().split('=')[1]);

		for (i in 1...num) {
			var title:String = lines.shift().split('=')[1].substr( 1 );
			var url:String = lines.shift().split('=')[1];

			var track = playlist.addTrack(title, url);
			trace(track.meta);
		}

		return playlist.tracks;
	}

/* === Instance Fields === */
	
	//- The Playlist instance which will hold all tracks read by [this] Reader
	public var playlist : Playlist;
}
