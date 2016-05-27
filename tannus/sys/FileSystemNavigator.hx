package tannus.sys;

import tannus.io.*;
import tannus.ds.*;

import Std.*;
import Math.*;
import tannus.math.TMath.*;
import tannus.TSys in Sys;
import tannus.sys.FileSystem in Fs;
import tannus.io.Asserts.*;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;

class FileSystemNavigator {
	/* Constructor Function */
	public function new(?cwd : Path):Void {
		pwd = (cwd != null ? cwd : HOME);
	}

/* === Instance Methods === */

	/**
	  * FileSystem list (ls equivalent)
	  */
	public function ls(?dir:Path, ?glob:GlobStar, all:Bool=false):Array<Path> {
		if (dir == null) dir = pwd;
		else dir = res( dir );

		if ( !all ) {
			var paths = Fs.readDirectory(dir.toString()).macmap(new Path(_));
			if (glob != null) {
				paths = paths.macfilter(glob.test( _.str ));
			}
			return paths;
		}
		else {
			var d = this.dir( dir );
			return d.gather(function(file : File):Bool {
				if (glob != null) {
					return glob.test(file.path.toString());
				} else return true;
			}).macmap( _.path );
		}
	}

	/**
	  * FileSystem read
	  */
	public inline function read(f:Path, ?length:Int):ByteArray {
		return Fs.read(res( f ), length);
	}

	/**
	  * FileSystem write
	  */
	public inline function write(f:Path, data:ByteArray):Void {
		Fs.write(res(f), data);
	}

	/**
	  * FileSystem remove
	  */
	public function rm(f:Path, force:Bool=false):Void {
		f = res( f );
		if (!Fs.isDirectory( f )) {
			Fs.deleteFile( f );
		}
		else {
			var empty:Bool = ls( f ).empty();
			if ( empty ) {
				Fs.deleteDirectory( f );
			}
			else if ( force ) {
				Fs.deleteDirectory( f );
			}
			else {
				throw 'directory not empty';
			}
		}
	}

	/**
	  * Create directory
	  */
	public function mkdir(dir : Path):Void {
		dir = res( dir );
		Fs.createDirectory( dir );
	}

	/**
	  * Get a File instance
	  */
	public inline function file(f : Path):File {
		return new File(res( f ));
	}

	/**
	  * Get a Directory instance
	  */
	public inline function dir(d:Path, ?create:Bool):Directory {
		return new Directory(res(d), create);
	}

	/**
	  * Execute a command
	  */
	public inline function system(cmd:String, args:Array<String>):Process {
		return new Process(cmd, args);
	}

	/**
	  * change [pwd] to [path]
	  */
	public function cd(path : Path):Void {
		if ( path.absolute ) {
			pwd = path;
		}
		else {
			pwd = pwd.resolve( path );
		}
		//validate( pwd );
		trace( pwd );
	}

	/**
	  * obtain a Path that is the result of resolving [p] from [pwd]
	  */
	public inline function res(p : Path):Path {
		return (p.absolute ? p : pwd.resolve( p ));
	}

	/**
	  * validate the given Path
	  */
	private inline function validate_nav(p : Path):Void {
		assert(Fs.exists(p.toString()) && Fs.isDirectory(p.toString()), '$p is not a valid directory');
	}
	private inline function validate(p : Path):Void {
		assert(Fs.exists(p.toString()), '$p is not a valid file or directory');
	}

/* === Instance Fields === */

	public var pwd(default, null): Path;

/* === Computed Static Fields === */

	/* The HOME directory */
	public static var HOME(get, never):Path;
	private static inline function get_HOME():Path {
		return new Path(Sys.getEnv('HOME'));
	}
}
