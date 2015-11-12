package tannus.format.xspf;

import tannus.io.ByteArray;
import tannus.ds.Stack;
import tannus.media.*;
import tannus.xml.Elem;

class Reader {
	/* Constructor Function */
	public function new():Void {

	}

	public function read(content : ByteArray):Playlist {
		var list:Playlist = new Playlist();
		var doc:Elem = Elem.parse(content.toString());
		
		return list;
	}
}
