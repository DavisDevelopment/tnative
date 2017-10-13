package tannus.html.fs;

import js.html.File;
import js.html.FileReader;
import tannus.html.fs.WebFileSystem;
import tannus.html.fs.WebFileWriter;

import tannus.ds.Promise;
import tannus.ds.Object;
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
	  * get the associated WebFile object
	  */
	public function getFile(cb : WebFile->Void):Void {
		var self = o;
		if (self.exists('_file')) {
			cb(untyped self['_file']);
		}
		else {
			this.file(function( f ) {
				self['_file'] = f;
				cb(cast f);
			}, function(err) throw err);
		}
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
		return cast Promise.create({
			getFile(function( file ) {
				var reader = new FileReader();
				reader.onerror = function(error) {
					throw error;
				};
				reader.onload = function(event) {
					//var data:ByteArray = ByteArray.ofData(cast event.target.result);
					return ByteArray.ofData(cast event.target.result);
				};
				reader.readAsArrayBuffer(cast file);
			});
		});
	}

	/**
	  * Obtain a writer for [this] File
	  */
	public function writer():Promise<WebFileWriter> {
		return Promise.create({
			createWriter((function(writer) return writer), (function(err) throw err));
		});
	}

	/**
	  * Obtain a writer
	  */
	public function createWriter(onsuccess:WebFileWriter->Void, ?onerror:Dynamic->Void):Void {
		this.createWriter(function(fw : FileWriter) onsuccess( fw ), onerror);
	}

	/**
	  * Move [this] Entry
	  */
	@:access( tannus.html.fs.WebDirectoryEntry )
	public function moveTo(parent:WebDirectoryEntry, ?name:String):Promise<WebFileEntry> {
		return Promise.create(@promise(_cast_) this.moveTo(parent, name));
	}

	/**
	  * Copy [this] Entry
	  */
	public function copyTo(parent:WebDirectoryEntry, ?name:String):Promise<WebFileEntry> {
		return Promise.create(@promise(_cast_) this.copyTo(parent, name));
	}

	/**
	  * Rename [this] Entry
	  */
	public function rename(newname : String):Promise<WebFileEntry> {
		return Promise.create({
			var pp = getDirectory();
			pp.then(function( parent ) {
				@forward moveTo(this, parent, newname);
			});
			pp.unless(function( error ) {
				throw error;
			});
		});
	}

	/**
	  * delete [this] file
	  */
	public inline function remove(?cb : Void->Void):Void {
		this.remove( cb );
	}

	/**
	  * get the directory that [this] file is in
	  */
	public inline function getDirectory():Promise<WebDirectoryEntry> {
		return Promise.create({
			this.getParent(function(parent) {
				if ( parent.isDirectory )
					return cast parent;
			}, (function(err) throw err));
		});
	}

	private var o(get, never):Object;
	private inline function get_o():Object return new Object(this);
}

typedef FileEntry = {
	> WebFSEntry,

	/* Get [this] FileEntry as a File */
	function file(onSuccess:File->Void, ?onFailure:Dynamic->Void):Void;

	/* Get a Writer for [this] File */
	function createWriter(onSuccess:FileWriter->Void, ?onFailure:Dynamic->Void):Void;
}

