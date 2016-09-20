package tannus.chrome;

import tannus.io.*;
import tannus.ds.*;
import tannus.ds.promises.*;
import tannus.html.fs.*;

using Lambda;
using tannus.ds.ArrayTools;
using tannus.ds.promises.PromiseTools;

class FileSystemTools {
/* === Class Methods === */

	public static inline function restoreAll(array:Array<String>):ArrayPromise<WebFSEntry> {
		return array.map( restorePromise ).batch();
	}

	private static function restorePromise(name:String):Promise<WebFSEntry> {
		return Promise.create({
			FileSystem.restoreEntry(name, function(entry) {
				return entry;
			});
		});
	}
}
