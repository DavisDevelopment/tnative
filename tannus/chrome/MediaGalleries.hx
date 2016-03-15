package tannus.chrome;

import tannus.sys.Path;
import tannus.sys.Mime;

import tannus.chrome.FileSystem in Fs;
import tannus.html.fs.WebFileSystem;
import tannus.html.fs.WebDirectoryEntry;
import tannus.html.fs.*;

@:access( tannus.html.fs.WebFile )
class MediaGalleries {
/* === Static Methods === */

	/**
	  * Get an Array of FileSystems in which media is stored
	  */
	public static inline function getMediaFileSystems(callback : Array<WebFileSystem> -> Void):Void {
		lib.getMediaFileSystems({}, callback);
	}

	/**
	  * Add a new Folder as a Gallery
	  */
	public static inline function addUserSelectedFolder(callback : Array<WebFileSystem> -> String -> Void):Void {
		lib.addUserSelectedFolder( callback );
	}

	/**
	  * get metadata for the given FileSystem
	  */
	public static inline function getMediaFileSystemMetadata(fileSystem : WebFileSystem):FileSystemMetadata {
		return lib.getMediaFileSystemMetadata( fileSystem );
	}

	/**
	  * Get the metadata for the given File
	  */
	public static function getMetadata(mediaFile:WebFile, callback:MetaData->Void):Void {
		lib.getMetadata(mediaFile.file, callback);
	}

/* === Static Fields === */

	private static var lib(get, never):Dynamic;
	private static inline function get_lib():Dynamic {
		return untyped __js__('chrome.mediaGalleries');
	}
}

typedef MetaData = {
	mimeType : Mime,
	?width : Int,
	?height : Int,
	?duration : Float,
	?album : String,
	?artist : String,
	?comment : String,
	?copyright : String,
	?disk : Int,
	?genre : String,
	?language : String,
	?title : String,
	?track : Int
};

typedef FileSystemMetadata = {
	name : String,
	galleryId : String,
	isAvailable : Bool
};
