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
	public static function getMetadata(mediaFile:Dynamic, callback:MetaData->Void):Void {
		lib.getMetadata(mediaFile, null, callback);
	}

	/**
	  * perform a Scan
	  */
	public static function scan(?complete:ScanResults->Void, ?progress:ScanResults->Void):Void {
		lib.onScanProgress.addListener(function(details : ScanResults):Void {
			switch ( details.type ) {
				case Finish:
					if (complete != null) {
						complete( details );
					}

				default:
					null;
			}

			if (progress != null) {
				progress( details );
			}
		});
		lib.startMediaScan();
	}

	/**
	  * Scan mediaGalleries
	  */
	public static function createScanner():MediaGalleryScanner {
		return new MediaGalleryScanner();
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

typedef ScanResults = {
	var type : ResultType;
	@:optional var galleryCount : Int;
	@:optional var audioCount : Int;
	@:optional var imageCount : Int;
	@:optional var videoCount : Int;
};

@:enum
abstract ResultType (String) {
	var Start = 'start';
	var Cancel = 'cancel';
	var Finish = 'finish';
	var Error = 'error';
}
