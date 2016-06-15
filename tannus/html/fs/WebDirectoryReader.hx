package tannus.html.fs;

import tannus.html.fs.WebFileSystem;
import tannus.html.fs.WebFSEntry;
import tannus.html.fs.WebFileEntry;
import tannus.html.fs.WebFileError in Err;
import tannus.html.fs.WebFileError.ErrorCode in Codes;
import tannus.sys.Path;
import tannus.ds.Object;
import tannus.ds.Obj;
import tannus.ds.Promise;
import tannus.ds.promises.*;
import tannus.ds.AsyncStack;
import tannus.sys.GlobStar;

using StringTools;
using tannus.ds.StringUtils;

abstract WebDirectoryReader (DirectoryReader) from DirectoryReader {
	/* Constructor Function */
	public inline function new(r : DirectoryReader):Void {
		this = r;
	}

/* === Instance Methods === */

	public function read():ArrayPromise<WebFSEntry> {
		var me:WebDirectoryReader = this;
		return Promise.create({
			function on_results(entries : Array<WebFSEntry>) {
				return me.__manip( entries );
			}

			function on_error(error : WebFileError) {
				throw error;
			}

			this.readEntries(on_results, on_error);
		}).array();
	}

	/**
	  * Manipulate the results
	  */
	private function __manip(entries : Array<WebFSEntry>):Array<WebFSEntry> {
		return entries;
	}

/* === Instance Fields === */

	/*
	private var middles(get, set):Array<MiddleFunc>;
	private inline function get_middles():Array<MiddleFunc> return (o.exists('middles') ? o['middles'] : jkjo

	private var o(get, never):Obj;
	private inline function get_o():Obj return untyped this._o;
	*/
}

typedef DirectoryReader = {
	function readEntries(success:Array<WebFSEntry>->Void, ?failure:Err->Void):Void;
};

//typedef MiddleFunc = Array<WebFSEntry> -> Array<WebFSEntry>;
//typedef FilterFunc = WebFSEntry -> Bool;
