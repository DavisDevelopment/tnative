package tannus.sys;

/* == Tannus Sys Imports == */
import tannus.sys.FileSystem;
import tannus.sys.FileStat;
import tannus.sys.Path;
import tannus.sys.Directory;
import tannus.sys.internal.FileContent;

/* == Tannus IO Imports == */
import tannus.io.Byte;
import tannus.io.ByteArray;
import tannus.io.Ptr;
import tannus.io.OutputStream;

@:forward
abstract File (CFile) {
	/* Constructor Function */
	public inline function new(p : Path):Void {
		this = new CFile(p);
	}

/* === Instance Fields === */

/* === Instance Methods === */

	/**
	  * Lines of content from [this] File
	  */
	public function lines(?nlines:Array<String>):Array<String> {
		if (nlines == null)
			return (this.read().toString().split('\n'));
		else {
			this.write(nlines.join('\n'));
			return nlines;
		}
	}

/* === Casting Methods === */

	#if node
		/**
		  * To node.WritableStream
		  */
		@:to
		public inline function toWritableStream():tannus.node.WritableStream {
			return tannus.sys.node.NodeFSModule.createWriteStream(this.path);
		}

	#end

/* === Class Methods === */

	/**
	  * Create a File object from a String
	  */
	@:from
	public static inline function fromString(p : String):File {
		return new File(p);
	}

	/**
	  * Create a File object from a Path
	  */
	@:from
	public static inline function fromPath(p : Path):File {
		return new File(p);
	}

	/**
	  * Create a File object from a ByteArray
	  */
	@:from
	public static inline function fromByteArray(p : ByteArray):File {
		return fromString( p );
	}
}

class CFile {
	/* Constructor Function */
	public function new(p : Path):Void {
		_path = p;
		
		//- validate that [path] is a File
		if (FileSystem.exists(path) && FileSystem.isDirectory(path)) {
			ferror('"$path" is a directory!');
		}
	}

/* === Instance Methods === */

	/**
	  * Reads the content of [this] File
	  */
	public inline function read():ByteArray {
		return FileSystem.read(path);
	}

	/**
	  * Writes new content to [this] File
	  */
	public inline function write(data : ByteArray):Void {
		FileSystem.write(path, data);
	}

	/**
	  * Appends [data] to [this] File
	  */
	public inline function append(data : ByteArray):Void {
		FileSystem.append(path, data);
	}

	/**
	  * Get an OutputStream to [this] File
	  */
	public function output():OutputStream {
		return FileSystem.ostream( path );
	}

	/**
	  * Renames [this] File
	  */
	public inline function rename(newpath : Path):Void {
		path = newpath;
	}

	/**
	  * Deletes [this] File
	  */
	public inline function delete():Void {
		FileSystem.deleteFile(path);
	}

/* === Computed Instance Fields === */

	/**
	  * Whether [this] File exists currently
	  */
	public var exists(get, never):Bool;
	private inline function get_exists():Bool {
		return FileSystem.exists(path);
	}

	/**
	  * The 'size' of [this] File
	  */
	public var size(get, never):Int;
	private function get_size():Int {
		var stats = FileSystem.stat(path);
		return stats.size;
	}

	/**
	  * The 'data' of [this] File
	  */
	public var data(get, set):ByteArray;
	private function get_data():ByteArray {
		return read();
	}
	private function set_data(nd : ByteArray):ByteArray {
		write( nd );
		return read();
	}

	/**
	  * The 'content' of [this] File
	  */
	public var content(get, never):FileContent;
	private function get_content():FileContent {
		var f:File = (cast this);
		return new FileContent(Ptr.create(f));
	}

	/**
	  * The path to [this] File
	  */
	public var path(get, set):Path;
	private inline function get_path():Path {
		return _path;
	}
	private function set_path(np : Path):Path {
		FileSystem.rename(_path, np);
		return (_path = np);
	}

	/**
	  * The Directory [this] File is in
	  */
	public var directory(get, never):Directory;
	private inline function get_directory():Directory {
		return (path.directory);
	}

	/**
	  * An Input, Bound to [this] File, for Buffered Reading
	  */
	public var input(get, never):haxe.io.Input;
	private inline function get_input():haxe.io.Input {
		#if (js || flash || python)
			var inp = new haxe.io.BytesInput(data);
			return inp;
		#else
			return sys.io.File.read(_path, true);
		#end
	}

/* === Instance Fields === */

	//- The path to [this] File
	private var _path : Path;

/* === Class Methods === */

	/**
	  * Throw a file-related error
	  */
	private static inline function ferror(msg : String):Void {
		throw 'FileError: $msg';
	}
}
