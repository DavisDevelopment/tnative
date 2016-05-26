package tannus.html.fs;

enum EntryType {
	FSFile(file : WebFileEntry);
	FSDirectory(directory : WebDirectoryEntry);
}
