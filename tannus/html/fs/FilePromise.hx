package tannus.html.fs;

import tannus.io.Signal;
import tannus.ds.Promise;
import tannus.ds.promises.*;
import tannus.html.fs.WebFile;
import tannus.html.fs.WebFileEntry;
import tannus.html.fs.WebFileEntry.FileEntry;
import tannus.html.fs.WebFileWriter;
import tannus.io.ByteArray;

import js.html.FileReader;

using tannus.html.fs.Macros;

class FilePromise extends Promise<WebFile> {
	/* Constructor Function */
	public function new(efunc : EntryAsync):Void {
		super(function(accept, reject) {
			efunc(function(e : WebFileEntry) {
				entry = e;
				gotentry.call( entry );
				var f:FileEntry = cast e;
				f.file(function(me) {
					accept(new WebFile(cast me));
				}, function(error) {
					reject( error );
				});
			});
		}, true);

		gotentry = new Signal();

		make();
	}

/* === Instance Methods === */

	/**
	  * get the writer for [this] File
	  */
	public function writer():Promise<WebFileWriter> {
		return Promise.create(withentry(@forward _.writer()));
	}

	/**
	  * promise to write some data to [this] File
	  */
	public function write(data : ByteArray):FilePromise {
		writer().then(function( writer ) {
			writer.write( data );
		});
		return this;
	}

	/**
	  * promise to read the data of [this] file when it is loaded
	  */
	public function read(pos:Int=0, ?len:Int):Promise<ByteArray> {
		return cast Promise.create({
			then(function( file ) {
				@forward file.read(pos, len);
			});
			unless(function( error ) {
				throw error;
			});
		});
	}

	/**
	  * async-safe method for getting the [entry] value
	  */
	public function useEntry(action : WebFileEntry -> Void):Void {
		if (entry == null) {
			gotentry.once( action );
		}
		else {
			action( entry );
		}
	}

/* === Instance Fields === */

	private var entry : Null<WebFileEntry> = null;
	private var gotentry : Signal<WebFileEntry>;
}

private typedef EntryAsync = EntryProvider -> Void;
private typedef EntryProvider = WebFileEntry -> Void;
