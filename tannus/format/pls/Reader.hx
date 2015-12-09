package tannus.format.pls;

import tannus.io.ByteArray;
import tannus.ds.Stack;

import tannus.media.Playlist;
import tannus.media.Track;

using StringTools;
using tannus.ds.StringUtils;

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
		var _lines:Array<String> = content.split('\n');
		_lines.shift();
		var num:Int = Std.parseInt(_lines.shift().split('=')[1]);
		var trackNum:Int = 0;
		var lines:Stack<String> = new Stack( _lines );

		while ( !lines.empty ) {
			if (lines.peek().trim() == '') {
				lines.pop();
				continue;
			}

			var track = new Track('', '');

			//var url:String = lines.shift().split('=')[1];
			if (~/Title([0-9]+)=/.match(lines.peek())) {
				var title:String = lines.pop().after('=');
				track.title = title;
			}

			if (~/Length([0-9]+)=/.match(lines.peek())) {
				var slen:String = lines.pop().after('=');
				track.duration.totalSeconds = Std.parseInt( slen );
			}

			var loc:String = lines.pop().after('=');
			track.location = loc;

			track.index = trackNum;
			
			playlist.addTrack( track );
			
			trackNum++;
		}

		return playlist.tracks;
	}

/* === Instance Fields === */
	
	//- The Playlist instance which will hold all tracks read by [this] Reader
	public var playlist : Playlist;
}
