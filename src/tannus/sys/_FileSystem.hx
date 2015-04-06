package tnative.sys;

import tnative.sys.FileStat;

/**
  * Wrapper around the NativeFileSystem class
  */
class FileSystem {
/* === Class Fields === */
	public static var exists:String->Bool;
	public static var isDirectory:String->Bool;
	public static var stat:String->FileStat;
	public static var deleteDirectory:String->Void;
	public static var deleteFile:String->Void;
	public static var rename:String->String->Void;
	public static var createDirectory:String->Void;

/* === Class Methods === */

	public static function readDirectory(path:String, recursive:Bool=false):Array<String> {
		return [];
	}
}

private typedef F = NativeFileSystem;
