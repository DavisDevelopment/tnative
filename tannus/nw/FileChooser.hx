package tannus.nw;

import tannus.io.*;
import tannus.html.Win;
import tannus.html.fs.*;
import tannus.sys.FSEntry;

import js.html.InputElement;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;
using Slambda;
using tannus.ds.AnonTools;

class FileChooser {
	/* Constructor Function */
	public function new():Void {
		multiple = false;
		directory = false;
	}

/* === Instance Methods === */

	/**
	  * Open [this] File Chooser dialog
	  */
	public function open(callback:Null<FileChooseResult>->Void):Void {
		var i = new tannus.nw.FileInput();
		i.multiple = multiple;
		i.directory = directory;

		i.changeEvent.once(function(val, files) {
			var entries = val.split(';').map.fn(FSEntry.fromString( _ ));
			var result:FileChooseResult = {
				webFileList: files,
				entries: entries
			};
			callback( result );
		});
		i.cancelEvent.once(function() {
			callback( null );
		});

		i.click();
	}

/* === Instance Fields === */

	public var multiple:Bool;
	public var directory:Bool;
}

@:structInit
class FileChooseResult {
	public var webFileList:WebFileList;
	public var entries:Array<FSEntry>;
}
