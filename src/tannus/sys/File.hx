package tannus.sys;

/* == Tannus Sys Imports == */
import tannus.sys.FileSystem;
import tannus.sys.FileStat;
import tannus.sys.Path;

/* == Tannus IO Imports == */
import tannus.io.Byte;
import tannus.io.ByteArray;
import tannus.io.Ptr;

@:forward
abstract File (CFile) {
	/* Constructor Function */
	public inline function new(p : Path):Void {
		this = new CFile(p);
	}

/* === Instance Fields === */

/* === Instance Methods === */

}

class CFile {
	/* Constructor Function */
	public function new(p : Path):Void {
		path = p;
		
		//- validate that [path] is a File
		if (FileSystem.exists(path) && FileSystem.isDirectory(path)) {
			ferror('"$path" is a directory!');
		}
	}

/* === Instance Methods === */

	/**
	  * Reads the content of [this] File
	  */
	public inline function read():ByteArray {
		return FileSystem.read(path);
	}

	/**
	  * Writes new content to [this] File
	  */
	public inline function write(data : ByteArray):Void {
		FileSystem.write(path, data);
	}

	/**
	  * Appends [data] to [this] File
	  */
	public inline function append(data : ByteArray):Void {
		FileSystem.append(path, data);
	}

/* === Computed Instance Fields === */

	/**
	  * Whether [this] File exists currently
	  */
	public var exists(get, never):Bool;
	private inline function get_exists():Bool {
		return FileSystem.exists(path);
	}

/* === Instance Fields === */

	//- The path to [this] File
	public var path : Path;

/* === Class Methods === */

	/**
	  * Throw a file-related error
	  */
	private static inline function ferror(msg : String):Void {
		throw 'FileError: $msg';
	}
}
