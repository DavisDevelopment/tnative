package tannus.html.fs;

import tannus.sys.Path;
import tannus.ds.Object;
import tannus.html.fs.WebDirectoryEntry in Dir;
import tannus.html.fs.WebFileSystem;

typedef WebFSEntry = {
	/* The name of [this] Entry */
	var name : String;

	/* The Path to [this] Entry */
	var fullPath : String;

	/* Whether [this] is a Directory */
	var isDirectory : Bool;

	/* Whether [this] is a File */
	var isFile : Bool;

	/* The FileSystem that [this] is attached to */
	var filesystem : WebFileSystem;

	/* Obtain the Metadata for [this] Entry */
	function getMetadata(success:Object->Void, ?failure:Dynamic->Void):Void;

	/* Move [this] Entry */
	function moveTo(parent:Dir, ?newname:String, ?success:WebFSEntry->Void, ?failure:Dynamic->Void):Void;

	/* Copy [this] Entry */
	function copyTo(parent:Dir, ?newname:String, ?success:WebFSEntry->Void, ?failure:Dynamic->Void):Void;

	/* Obtain a URL to [this] File */
	function toURL(?mime : String):String;

	/* Delete [this] Entry */
	function remove(?success:Void->Void, ?failure:Dynamic->Void):Void;

	/* Get a reference to the parent-entry of [this] one */
	function getParent(success:WebFSEntry->Void, ?failure:Dynamic->Void):Void;
};
