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
import tannus.ds.AsyncStack;
import tannus.sys.GlobStar;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;

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
	public inline function getDirectory(path : Path):Promise<WebDirectoryEntry> {
		return new Promise(this.getDirectory.bind(path, {}));
	}

	/**
	  * Obtain a List of Entries within [this] Directory
	  */
	public inline function readEntries():ArrayPromise<WebFSEntry> {
		return this.createReader().read();
	}

	/**
	  * Get all Subdirectories of [this]
	  */
	public function getDirectories():ArrayPromise<WebDirectoryEntry> {
		return readEntries().filter.fn( _.isDirectory ).map.fn(new WebDirectoryEntry(cast _));
	}

	/**
	  * get an Array of all FileEntries recursively
	  */
	public function walk(cb:Array<WebFileEntry>->Void, ?filter:WebFileEntry->Bool, ?step:WebFileEntry->Bool):Void {
		var all:Array<WebFileEntry> = new Array();
		readEntries().then(function( entries ) {
			var stack = new AsyncStack();
			var broken:Bool = false;
			for (e in entries) {
				stack.push(function(done) {
					if ( broken ) {
						done();
						return ;
					}

					if ( e.isFile ) {
						var add = (filter == null || filter(new WebFileEntry(cast e)));
						if ( add ) {
							var wfe = new WebFileEntry(cast e);
							if (step != null) {
								var continu = step( wfe );
								if ( !continu ) {
									broken = true;
								}
							}
							all.push( wfe );
						}
						done();
					}
					else {
						var _f:WebDirectoryEntry = new WebDirectoryEntry(cast e);
						_f.walk(function( sub ) {
							all = all.concat( sub );
							done();
						}, filter);
					}
				});
			}
			stack.run(function() {
				cb( all );
			});
		});
	}

	/**
	  * Get an Array of all FileEntries recursively
	  */
	/*
	public function walk(?tester : WebFileEntry->Bool):ArrayPromise<WebFileEntry> {
		return Promise.create({
			var stack:AsyncStack = new AsyncStack();
			var files:Array<WebFileEntry> = new Array();
			readEntries().then(function( entries ) {
				for (e in entries) {
					stack.push(function( done ) {
						if ( e.isFile ) {
							if (tester == null || tester(cast e)) {
								files.push(cast e);
							}
							done();
						}
						else if ( e.isDirectory ) {
							var p = new WebDirectoryEntry(cast e).walk(tester);
							p.then(function(dfiles) {
								files = files.concat( dfiles );
								done();
							});
							p.unless(function(error) {
								throw error;
							});
						}
					});
				}

				stack.run(function() {
					return files;
				});
			}).unless(function(error) throw error);
		}).array();
	}
	*/
}

typedef DirectoryEntry = {
	> WebFSEntry,

	/* Obtain a Reader for [this] Directory */
	function createReader():WebDirectoryReader;

	/* Get a File Reference */
	function getFile(path:Path, options:Object, success:WebFileEntry->Void, failure:Err->Void):Void;

	/* Get a Directory Reference */
	function getDirectory(path:Path, options:Object, success:WebDirectoryEntry->Void, failure:Dynamic->Void):Void;

	/* Delete [this] Directory */
	function removeRecursively(success:Void->Void, failure:Dynamic->Void):Void;
}
