package tannus.html.fs;

import tannus.html.fs.EntryType;

class FileSystemTools {
	/**
	  * get an EntryType for a WebFSEntry
	  */
	public static function getType(e : WebFSEntry):EntryType {
		if ( e.isDirectory ) {
			return FSDirectory(new WebDirectoryEntry(cast e));
		}
		else if ( e.isFile ) {
			return FSFile(new WebFileEntry(cast e));
		}
		else {
			throw 'FileSystemError: The given entry is neither a File or a Directory';
		}
	}
}
