package tannus.chrome.mg;

import tannus.html.fs.*;
import tannus.sys.Path;
import tannus.chrome.MediaGalleries.MetaData;

import Std.*;
import Std.string in s;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;

class GalleryEntry {
	/* Constructor Function */
	public function new(e : WebFileEntry):Void {
		entry = e;
		fullPath = Path.fromString(s( entry.fullPath ));
	}

/* === Instance Methods === */

	/**
	  * get metadata for [this] Entry
	  */
	public inline function getMetaData(cb : MetaData -> Void):Void {
		entry.file().then(function(file) MediaGalleries.getMetadata((untyped file.file), cb));
	}

/* === Instance Fields === */

	public var fullPath : Path;
	public var entry : WebFileEntry;
}
