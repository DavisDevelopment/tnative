package tannus.format.xspf;

import Xml;
import tannus.io.ByteArray;
import tannus.media.Playlist;
import tannus.media.Track;
import tannus.format.Writer in Writ;

import tannus.xml.Elem;

class Writer extends Writ {
	public var pl:Playlist;
	public function new(_pl : Playlist):Void {
		super();
		pl = _pl;
	}

/* === Instance Methods === */

	/* Generate the XSPF data */
	public function write():ByteArray {
		var root = new Elem('playlist');
		root.set('version', '1');
		root.set('xmlns', 'http://xspf.org/ns/0/');
		
		var tl = new Elem('trackList', root);

		for (t in pl.tracks) {
			tl.addChild(track( t ));
		}

		var data:String = (root.toXml() + '');
		data = ('<?xml version="1.0" encoding="UTF-8"?>\n' + data);

		return data;
	}

	/* Generate a <track> Elem */
	public function track(t : Track):Elem {
		var tel = new Elem('track');
		
		var title = new Elem('title', tel);
		title.text = t.title;

		var locel = new Elem('location', tel);
		locel.text = t.location;

		var dur = new Elem('duration', tel);
		dur.text = (t.duration.totalSeconds * 1000)+'';

		if (t.index > 0) {
			var traknum = new Elem('trackNum', tel);
			trakNum.text = (t.index + '');
		}

		return tel;
	}
}
