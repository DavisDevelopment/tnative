package tannus.node;

import tannus.async.Cb;
import tannus.async.VoidCb;

import tannus.sys.node.NodeFStat;
import tannus.node.Buffer;

import haxe.extern.EitherType;

@:jsRequire( 'fs' )
extern class Fs {
	/* Check for existence */
	public static function existsSync(path : String):Bool;
	public static function exists(path:String, callback:Bool->Void):Void;

	/* Check whether [path] is a directory */
	public static function statSync(path : String):NodeFStat;
	public static function stat(path:String, callback:Cb<NodeFStat>):Void;

	/* Create directory */
	public static function mkdirSync(path : String):Void;
	public static function mkdir(path:String, callback:VoidCb):Void;

	/* Delete directory */
	public static function rmdirSync(path : String):Void;
	public static function rmdir(path:String, callback:VoidCb):Void;

	/* Delete file */
	public static function unlinkSync(path : String):Void;
	public static function unlink(path:String, callback:VoidCb):Void;

	/* Reads directory */
	public static function readdirSync(path : String):Array<String>;
	public static function readdir(path:String, callback:Cb<Array<String>>):Void;

	/* Reads file */
	public static function readFileSync(path : String):Dynamic;
	public static function readFile(path:String, callback:Cb<Buffer>):Void;

	/* Writes to file */
	public static function writeFileSync(path:String, data:Dynamic):Void;
	public static function writeFile(path:String, data:Dynamic, ?options:FsWriteFileOptions, callback:VoidCb):Void;

	/* Renames file */
	public static function renameSync(o:String, n:String):Void;
	public static function rename(o:String, n:String, callback:VoidCb):Void;

    public static function copyFile(src:String, dest:String, callback:VoidCb):Void;
    public static function copyFileSync(src:String, dest:String):Void;

	public static function truncate(path:String, len:Int, callback:VoidCb):Void; public static function truncateSync(path:String, len:Int):Void;

	public static function chmodSync(path:String, mod:Int):Void;
	public static function chmod(path:String, mod:Int, callback:VoidCb):Void;

	/* Open a Writable Stream to a File */
	public static function createWriteStream(path:String, ?options:Dynamic):tannus.node.WritableStream;

	/* Open a Readable Stream from a File */
	public static function createReadStream(path:String, ?options:CreateReadStreamOptions):FileReadStream;

	public static function openSync(path:String, flags:String):Int;
	public static function readSync(id:Int, buffer:Buffer, offset:Int, length:Int, position:Int):Int;
	public static function writeSync(id:Int, buffer:Buffer, offset:Int, length:Int, position:Int):Int;
	public static function closeSync(id:Int):Void;

    public static function open(path:String, flags:String, callback:Cb<Int>):Void;
    public static function read(id:Int, buffer:Buffer, offset:Int, length:Int, position:Null<Int>, callback:?Dynamic->?Int->?Buffer->Void):Void;
	public static function close(id:Int, callback:VoidCb):Void;

	public static function watch(path:String, listener:String->String->Void):FSWatcher;
}

@:jsRequire('fs', 'FSWatcher')
extern class FSWatcher extends EventEmitter {
    function close():Void;
}

typedef FsWriteFileOptions = {
    ?encoding: String,
    ?mode: Int,
    ?flag: String
};

@:jsRequire('fs', 'Stats')
extern class Stats {
	public function isFile():Bool;
	public function isDirectory():Bool;

	public var size : Int;
	public var mtime : Date;
	public var ctime : Date;
}

@:jsRequire('fs', 'ReadStream')
extern class FileReadStream extends ReadableStream {
    public var bytesRead: Int;
    public var path: EitherType<String, Buffer>;

    public inline function onOpen(cb: Int->Void):Void this.on('open', cb);
    //public inline function onClose(f: Void->Void):Void this.on('close', f);
}

typedef CreateReadStreamOptions = {
    ?flags: String,
    ?encoding: String,
    ?fd: Int,
    ?mode: Int,
    ?autoClose: Bool,
    ?start: Int,
    ?end: Int,
    ?highWaterMark: Int
};
