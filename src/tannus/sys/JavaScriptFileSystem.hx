package tannus.sys;

import tannus.io.ByteArray;
import tannus.io.Byte;
import tannus.io.Ptr;
import tannus.sys.FileStat;
import tannus.sys.Path;
import tannus.sys.VirtualVolume;

/**
  * FileSystem Polyfill for Client-Side JavaScript
  */
class JavaScriptFileSystem {
/* === Class Fields === */

	private static var volume:VirtualVolume;

/* === Utility Methods === */

	public static function __init__():Void {
		load();
	}

	/**
	  * Initialize [volume]
	  */
	private static function load():Void {
		var ls = js.Browser.getLocalStorage();
		var saved:Null<String> = ls.getItem('::fs::');
		
		if (saved == null) {
			volume = new VirtualVolume('fs');
			save();
		}
		else {
			volume = VirtualVolume.deserialize( saved );
		}
	}

	/**
	  * Persist [volume] to Storage
	  */
	private static function save():Void {
		var ls = js.Browser.getLocalStorage();
		var data = volume.serialize();
		ls.setItem('::fs::', data);
	}

/* === FileSystem Methods === */

	private static var v(get, never):VirtualVolume;
	private static inline function get_v():VirtualVolume {
		return volume;
	}

	/**
	  * Check for existence of an Entry
	  */
	public static function exists(name : String):Bool {
		return v.exists(name);
	}

	/**
	  * Check if entry is a Directory
	  */
	public static function isDirectory(name : String):Bool {
		return v.isDirectory(name);
	}

	/**
	  * Create new directory
	  */
	public static function createDirectory(name : String):Void {
		v.createDirectory(name);
		save();
	}

	/**
	  * Delete directory
	  */
	public static function deleteDirectory(name : String):Void {
		v.deleteDirectory(name);
		save();
	}

	/**
	  * Delete a File
	  */
	public static inline function deleteFile(name : String):Void {
		v.deleteFile(name);
		save();
	}

	/**
	  * Get a list of all entries in the given directory
	  */
	public static function readDirectory(name : String):Array<String> {
		return v.readDirectory(name);
	}

	/**
	  * Reads the content of a File
	  */
	public static function read(name : String):ByteArray {
		return v.read(name);
	}

	/**
	  * Write the given data to a File
	  */
	public static function write(name:String, data:ByteArray):Void {
		v.write(name, data);
		save();
	}

	/**
	  * Append the given data to a File
	  */
	public static function append(name:String, data:ByteArray):Void {
		v.append(name, data);
		save();
	}

	/**
	  * Rename the given file
	  */
	public static inline function rename(o:String, n:String):Void {
		v.rename(o, n);
		save();
	}

	/**
	  * Gets the stats on a given file
	  */
	public static inline function stat(name : String):FileStat {
		return v.stat(name);
	}
}
