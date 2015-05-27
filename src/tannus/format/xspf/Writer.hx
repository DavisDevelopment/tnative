package tannus.format.xspf;

import Xml;
import tannus.io.ByteArray;
import tannus.media.Playlist;
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
		var tl = new Elem('trackList');
		root.addChild(tl);

		for (t in pl.tracks) {
			tl.addChild(track(t.name, t.location));
		}

		var data:String = (root.toXml() + '');
		data = ('<?xml version="1.0" encoding="UTF-8"?>\n' + data);

		return data;
	}

	/* Generate a <track> Elem */
	public function track(n:String, l:String):Elem {
		return Elem.parse('<track><title>$n</title><location>$l</location></track>');
	}
}
