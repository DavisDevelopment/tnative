package tannus.html.fs;

import js.html.FileList;

abstract WebFileList (FileList) from FileList {
	/* Constructor Function */
	public inline function new(l : FileList):Void {
		this = l;
	}

/* === Instance Methods === */

	/**
	  * Get a WebFile
	  */
	@:arrayAccess
	public inline function item(index : Int):WebFile {
		return new WebFile(this[index]);
	}

	/**
	  * iterate over [this] FileList
	  */
	public inline function iterator():FileListIterator {
		return new FileListIterator( this );
	}

/* === Instance Fields === */

	/* the number of files */
	public var length(get, never):Int;
	private inline function get_length():Int return this.length;
}

private class FileListIterator {
	/* Constructor Function */
	public inline function new(wfl : WebFileList):Void {
		list = wfl;
		ii = (0...list.length);
	}

/* === Instance Methods === */

	public inline function hasNext():Bool return ii.hasNext();
	public inline function next():WebFile return list[ii.next()];

/* === Instance Fields === */

	private var list : WebFileList;
	private var ii : IntIterator;
}
