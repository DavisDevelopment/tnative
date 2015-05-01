package tannus.sys.fquery;

enum Token {
	/* Literal Directory Name */
	TLiteralDirectoryName(dir : String);

	/* Literal File Name */
	TLiteralFileName(fn : String);
}
