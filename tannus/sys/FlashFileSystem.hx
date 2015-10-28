package tannus.sys;

import tannus.io.ByteArray;
import tannus.io.Byte;
import tannus.io.Ptr;
import tannus.sys.FileStat;
import tannus.sys.Path;
import tannus.sys.VirtualVolume;

import flash.net.SharedObject;

/**
  * FileSystem Polyfill for the Flash Target
  */
class FlashFileSystem {
/* === Class Fields === */
	private static var volume:VirtualVolume;

/* === Utility Methods === */

	/**
	  * Checks for the existence of the 'fs' SharedObject,
	  * if found, loads a VirtualVolume from that, otherwise, creates
	  * a new VirtualVolume
	  */
	private static function load():Void {
		var so:SharedObject = SharedObject.getLocal('fs');
		var dat:Dynamic = so.data;
		var saved:Null<flash.utils.ByteArray> = dat.volume;

		if (saved == null) {
			volume = new VirtualVolume('fs');
			so.close();
			save();
		}
		else {
			volume = VirtualVolume.deserialize( saved );
		}
	}

	/**
	  * Persists [volume] to the SharedObject
	  */
	private static function save():Void {
		var so:SharedObject = SharedObject.getLocal('fs');
		
		var data:flash.utils.ByteArray = volume.serialize().toFlashByteArray();
		so.setProperty('volume', data);
	}

	/**
	  * Initialize [this] Class
	  */
	public static function __init__():Void {
		load();
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
