package tannus.html.fs;

import js.html.File;
import js.html.FileReader;
import tannus.html.fs.WebFileSystem;
import tannus.html.fs.WebFileWriter;

import tannus.ds.Promise;
import tannus.ds.promises.*;
import tannus.io.ByteArray;

@:forward(name, fullPath, isDirectory, isFile)
abstract WebFileEntry (FileEntry) from FileEntry {
	/* Constructor Function */
	public inline function new(entry : FileEntry):Void {
		this = entry;
	}

/* === Instance Fields === */

	/**
	  * The FileSystem that [this] is attached to
	  */
	public var fileSystem(get, never):WebFileSystem;
	private inline function get_fileSystem() return cast this.filesystem;

/* === Instance Methods === */


	/**
	  * Do Stuff
	  */
	public inline function file():FilePromise {
		return new FilePromise(function(give) give( this ));
	}

	/**
	  * Get the size of [this] File
	  */
	public inline function size():Promise<Int> {
		return file().transform(function(f) return (f.size));
	}

	/**
	  * Get the mime-type of the File
	  */
	public inline function type():StringPromise {
		return file().transform(function(f) {
			return (f.type);
		}).string();
	}
	
	/**
	  * Read the Bytes of [this] File into memory
	  */
	public function read():Promise<ByteArray> {
		return Promise.create({
			this.file(function(file) {
				var reader = new FileReader();
				reader.onerror = function(error) {
					throw error;
				};
				reader.onload = function(event) {
					var data:ByteArray = ByteArray.ofData(cast event.target.result);
					return data;
				};
				reader.readAsArrayBuffer(cast file);
			}, function(error) {
				throw error;
			});
		});
	}

	/**
	  * Obtain a writer for [this] File
	  */
	public function writer():Promise<WebFileWriter> {
		return Promise.create({
			this.createWriter((function(writer) return writer), (function(err) throw err));
		});
	}
}

typedef FileEntry = {
	> WebFSEntry,

	/* Get [this] FileEntry as a File */
	function file(onSuccess:File->Void, ?onFailure:Dynamic->Void):Void;

	/* Get a Writer for [this] File */
	function createWriter(onSuccess:WebFileWriter->Void, ?onFailure:Dynamic->Void):Void;
}

