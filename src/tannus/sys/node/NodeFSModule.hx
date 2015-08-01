package tannus.sys.node;

import tannus.sys.node.NodeFStat;

@:jsRequire('fs')
extern class NodeFSModule {
	/* Check for existence */
	public static function existsSync(path : String):Bool;

	/* Check whether [path] is a directory */
	public static function statSync(path : String):NodeFStat;

	/* Create directory */
	public static function mkdirSync(path : String):Void;

	/* Delete directory */
	public static function rmdirSync(path : String):Void;

	/* Delete file */
	public static function unlinkSync(path : String):Void;

	/* Reads directory */
	public static function readdirSync(path : String):Array<String>;

	/* Reads file */
	public static function readFileSync(path : String):Dynamic;

	/* Writes to file */
	public static function writeFileSync(path:String, data:Dynamic):Void;

	/* Renames file */
	public static function renameSync(o:String, n:String):Void;

	/* Open a Writable Stream to a File */
	public static function createWriteStream(path:String, ?options:Dynamic):tannus.node.WritableStream;
}
