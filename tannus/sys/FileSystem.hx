package tannus.sys;

import tannus.io.ByteArray;
import tannus.sys.FileStat;
import tannus.sys.Path;
import tannus.sys.FileStreamOptions in Fso;

#if flash

typedef FileSystem = tannus.sys.FlashFileSystem;

#elseif node

typedef FileSystem = tannus.sys.node.NodeFileSystem;

#elseif js

typedef FileSystem = tannus.sys.JavaScriptFileSystem;

#else

import haxe.io.Output;
import tannus.io.streams.NativeOutputStream in OStream;
import tannus.io.OutputStream;

/**
  * Wrapper around the Haxe STD's sys.FileSystem class (or, in Node's case the 'fs' module)
  */
class FileSystem {
	/**
	  * Checks for the existence of a file or directory
	  */
	public static function exists(path : String):Bool {
		return FS.exists(path);
	}

	/**
	  * Checks that [path] is a directory
	  */
	public static inline function isDirectory(path : String):Bool {
		return FS.isDirectory(path);
	}

	/**
	  * Create's a new directory
	  */
	public static function createDirectory(dir : String):Void {
		try {
			FS.createDirectory( dir );
		} catch (error : Dynamic) {
			throw 'IOError: Cannot create directory "$dir"!';
		}
	}

	/**
	  * Deletes a directory
	  */
	public static function deleteDirectory(dir : String):Void {
		try {
			FS.deleteDirectory(dir);
		} catch (error : Dynamic) {
			throw 'IOError: Cannot create directory "$dir"!';
		}
	}

	/**
	  * Returns a list of all entries in the given directory
	  */
	public static function readDirectory(dir:String, recursive:Bool=false):Array<String> {
		if (!recursive) {
			
			return FS.readDirectory( dir );
		} 
		
		else {
			throw 'Unimplemented!';
			return [];
		}
	}

	/**
	  * Writes data to a file, and creates it if it doesn't already exist
	  */
	public static function write(path:String, data:ByteArray):Void {
		#if python
			var ba:Dynamic = python.Syntax.pythonCode('bytearray()');

			for (i in data.toArray()) {
				ba.append(i.asint);
			}

			var f:Dynamic = python.Syntax.pythonCode('open(path, "w+")');
			f.write(ba);
			f.close();
		#else
			F.saveBytes(path, data);
		#end
	}

	/**
	  * Opens and Returns an Output instance, bound to the given File
	  */
	public static function fileOutput(path : String):sys.io.FileOutput {
		#if python
			return untyped (new tannus.sys.PyFileOutput( path ));
		#else
			return sys.io.File.write(path, true);
		#end
	}

	/**
	  * Reads data from a file, and returns it
	  */
	public static inline function read(path:String, ?length:Int):ByteArray {
		#if python
			var p:String = path;
			var f:Dynamic = python.Syntax.pythonCode('open(p, "rb")');
			var _data:Dynamic = (length!=null?f.read():f.read(length));
			_data = python.Syntax.pythonCode('list(_data)');
			var data:Array<Int> = cast _data;
			f.close();

			return ByteArray.fromIntArray( data );
		#else
			var b:haxe.io.Bytes = F.getBytes(path);
			return ByteArray.fromBytes(b);
		#end
	}

	/**
	  * Appends [data] to a file
	  */
	public static function append(path:String, data:ByteArray):Void {
		#if python
			var p:String = path;
			var f:Dynamic = python.Syntax.pythonCode('open(p, "ab")');
			var _data:Dynamic = python.Syntax.pythonCode('bytearray()');
			for (i in data.toArray()) {
				_data.append(i.asint);
			}
			f.write( _data );
		#else
			var out = F.append(path, true);
			out.write( data );
			out.close();
		#end
	}

	/**
	  * Creates a readable Stream from a File
	  */
	public static function istream(path:String, options:Fso):IStream {
		throw 'Error: Not implemented!';
	}

	/**
	  * Create a writable Stream to a File
	  */
	public static function ostream(path : String):OutputStream {
		// create a new FileOutput to [path]
		var file_out:Output = F.write( path );
		// wrap [file_out] in a tannus.io.streams.NativeOutputStream object
		var nos:OStream = new OStream( file_out );
		// wrap [nos] in a tannus.io.OutputStream object
		var out:OutputStream = new OutputStream( nos );
		return out;
	}

	/**
	  * Moves the given path to a new one
	  */
	public static function rename(oldpath:String, newpath:String):Void {
		FS.rename(oldpath, newpath);
	}

	/**
	  * Deletes the given file
	  */
	public static inline function deleteFile(path : String):Void {
		FS.deleteFile(path);
	}

	/**
	  * Retrieves the stats of the file
	  */
	public static function stat(path : String):FileStat {
		var s = FS.stat(path);
		
		return {
			'size' : s.size,
			'mtime': s.mtime,
			'ctime': s.ctime
		};
	}
}

private typedef FS = sys.FileSystem;
private typedef F = sys.io.File;

#end

private typedef IStream = Dynamic;
