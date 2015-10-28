package tannus.html.fs;

import tannus.html.fs.WebFileSystem;
import tannus.html.fs.WebFSEntry;
import tannus.html.fs.WebFileEntry;
import tannus.html.fs.WebFileError in Err;
import tannus.html.fs.WebFileError.ErrorCode in Codes;
import tannus.sys.Path;
import tannus.ds.Object;
import tannus.ds.Promise;
import tannus.ds.promises.*;
import tannus.sys.GlobStar;

using StringTools;
using tannus.ds.StringUtils;

@:forward
abstract WebDirectoryEntry (DirectoryEntry) from DirectoryEntry {
	/* Constructor Function */
	public inline function new(dir : DirectoryEntry):Void {
		this = dir;
	}

/* === Instance Methods === */

	/**
	  * Check for the existence of a File in [this] Directory
	  */
	public inline function exists(path : Path):BoolPromise {
		return Promise.create({
			this.getFile(
				path, null,
				(function(entry) return true),
				(function(error) {
					switch(error.code) {
						case NotFound:
							return false;
						default:
							throw error;
					}
				})
			);
		}).bool();
	}

	/**
	  * Create a new File
	  */
	public inline function createFile(path : Path):Promise<WebFileEntry> {
		return new Promise(this.getFile.bind(path, {'create': true}));
	}

	/**
	  * Get a reference to a File
	  */
	public inline function getFile(path:Path):Promise<WebFileEntry> {
		return new Promise(this.getFile.bind(path, {}, _, _));
	}

	/**
	  * Create a new Directory
	  */
	public inline function createDirectory(path : Path):Promise<WebDirectoryEntry> {
		return new Promise(this.getDirectory.bind(path, {'create': true}));
	}

	/**
	  * Obtain a List of Entries within [this] Directory
	  */
	public inline function readEntries():ArrayPromise<WebFSEntry> {
		return new ArrayPromise(this.createReader().readEntries.bind(_, _));
	}

	/**
	  * Get all entries which match a given Filter
	  */
	public function filter(glob : GlobStar):ArrayPromise<WebFSEntry> {
		return (readEntries().filter(function(e) {
			return (glob.test(e.name));
		}));
	}
}

typedef DirectoryEntry = {
	> WebFSEntry,

	/* Obtain a Reader for [this] Directory */
	function createReader():DirectoryReader;

	/* Get a File Reference */
	function getFile(path:Path, options:Object, success:WebFileEntry->Void, failure:Err->Void):Void;

	/* Get a Directory Reference */
	function getDirectory(path:Path, options:Object, success:WebDirectoryEntry->Void, failure:Dynamic->Void):Void;

	/* Delete [this] Directory */
	function removeRecursively(success:Void->Void, failure:Dynamic->Void):Void;
}

typedef DirectoryReader = {
	function readEntries(success:Array<WebFSEntry>->Void, ?failure:Err->Void):Void;
};
