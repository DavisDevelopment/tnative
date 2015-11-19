package tannus.chrome;

import tannus.html.fs.WebFileEntry;
import tannus.html.fs.WebFSEntry;
import tannus.html.fs.WebDirectoryEntry in Dir;
import tannus.sys.Path;

import tannus.ds.Promise;

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
		lib.chooseEntry(options, function(entry:WebFSEntry) {
			var all:Array<WebFSEntry> = new Array();
			if (entry != null) {
				if (Std.is(entry, Array))
					all = all.concat(untyped entry);
				else
					all.push(entry);
			}
			var _all:Array<Array<WebFSEntry>> = untyped all;
			all = tannus.ds.ArrayTools.flatten(_all);
			cb( all );
		});
	}

	/**
	  * Obtain a restorable id for an Entry
	  */
	public static inline function retainEntry(entry : WebFSEntry):String {
		return lib.retainEntry( entry );
	}

	/**
	  * Restore an Entry from an id
	  */
	public static inline function restoreEntry(id:String, cb:WebFSEntry->Void):Void {
		lib.restoreEntry(id, cb);
	}

	/**
	  * Check whether a given entry-id is restorable
	  */
	public static inline function isRestorable(id:String, cb:Bool->Void):Void {
		lib.isRestorable(id, cb);
	}

	/**
	  * Get a Directory from the User
	  */
	public static function chooseDirectory():Promise<Dir> {
		return Promise.create({
			chooseEntry({type:OpenDirectory}, function(entries) {
				var e = entries.shift();
				if (e == null || !e.isDirectory)
					throw 'Not a Directory!';
				else
					return new Dir(cast e);
			});
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
