package tannus.chrome;

import tannus.html.fs.WebFileEntry;
import tannus.html.fs.WebFSEntry;
import tannus.sys.Path;

import Std.is;

class FileSystem {
	/**
	  * Request a FileSystem
	  */
	public static function requestFileSystem(volume:String, cb:Dynamic->Void):Void {
		lib.requestFileSystem({'volumeId':volume, 'writable':true}, cb);
	}

	/**
	  * Get the List of Volumes
	  */
	public static function getVolumeList(cb : Array<Volume>->Void):Void {
		lib.getVolumeList( cb );
	}

	/**
	  * Ask the User to choose a File or Directory
	  */
	public static function chooseEntry(options:ChooseEntryOptions, cb:Array<WebFSEntry>->Void):Void {
		lib.chooseEntry(options, function(entry:WebFSEntry, ?entries:Array<WebFSEntry>) {
			var all:Array<WebFSEntry> = new Array();
			if (is(entry, Array)) {
				all = cast entries;
			} else all = [entry];
			untyped all = all.shift();

			cb( all );
		});
	}

	/**
	  * Get the Full Path to a File
	  */
	public static function getDisplayPath(entry:WebFileEntry, cb:Path->Void):Void {
		lib.getDisplayPath(entry, cb);
	}

	/**
	  * Underlying object
	  */
	private static var lib(get, never):Dynamic;
	private static inline function get_lib() return untyped __js__('chrome.fileSystem');
}

typedef Volume = {
	var volumeId : String;
	var writable : Bool;
};

@:enum
abstract OpenEntryType (String) from String to String {
	var OpenFile = 'openFile';
	var OpenWritable = 'openWritableFile';
	var OpenDirectory = 'openDirectory';
	var SaveFile = 'saveFile';
}

typedef ChooseEntryOptions = {
	?type : OpenEntryType,
	?suggestedName : String,
	?acceptsAllTypes : Bool,
	?acceptsMultiple : Bool,
	?accepts : {
		?description:String,
		?mimeTypes:Array<String>,
		?extensions:Array<String>
	}
};
