package tannus.format.wpl;

import tannus.format.Writer in BaseWriter;
import tannus.xml.Elem;
import tannus.media.Playlist;
import tannus.io.ByteArray;

class Writer extends BaseWriter {
	/* Constructor Function */
	public function new(pl : Playlist):Void {
		super();

		playlist = pl;
	}

/* === Instance Methods === */

	/**
	  * Generate the WPL Data
	  */
	public function generate():ByteArray {
		root = new Elem('smil');
		head = new Elem('head');
		meta('Generator', 'Bassist Chrome Extension');
		var td:Float = 0;
		for (t in playlist.tracks)
			td += t.duration.totalSeconds;
		meta('TotalDuration', td);
		meta('ItemCount', playlist.tracks.length);
		var author = new Elem('author');
		head.addChild( author );
		var title = new Elem('title');
		title.text = playlist.title;

		body = new Elem('body');
		root.addChild(body);

		var seq = new Elem('seq');
		body.addChild( seq );
		
		for (track in playlist.tracks) {
			var med = new Elem('media');
			med.set('src', track.location);
			seq.addChild( med );
		}

		var data:String = (root.toXml() + '');
		line('<?wpl version="1.0"?>');
		w( data );
		return buffer;
	}

	/**
	  * Add a <meta> tag to [head]
	  */
	private inline function meta(key:String, val:Dynamic):Void {
		var mel = new Elem('meta');
		mel.set('name', key);
		mel.set('content', Std.string(val));
		head.addChild(mel);
	}

/* === Instance Fields === */

	public var playlist : Playlist;
	public var root : Elem;
	public var head : Elem;
	public var body : Elem;
}
