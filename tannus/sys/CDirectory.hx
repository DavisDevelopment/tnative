package tannus.sys;

import tannus.sys.Path;
import tannus.sys.FileSystem.*;
import tannus.sys.FileSystem in Fs;
import tannus.sys.FSEntry;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;

class CDirectory {
	/* Constructor Function */
	public function new(path:Path, create:Bool=false):Void {
		_path = path;
		
		if (Fs.exists( _path )) {
			if (!isDirectory( _path )) 
				throw 'IOError: $path is not a Directory!';
		} 
		else {
			if ( create ) 
				createDirectory( _path );
			else
				throw 'IOError: $path is not a File or a Directory!';
		}
	}

/* === Instance Methods === */

	/* get an FSEntry by name */
	public inline function getEntry(name : String):Null<FSEntry> {
		return (hasEntry( name ) ? FSEntry.fromPath(path + name) : null);
	}

	/* check whether an entry named [name] is contained in [this] Directory */
	public function hasEntry(name : String):Bool {
		var pp = path.plusString( name );
		if (path.absolute)
			pp = pp.absolutize();
		return Fs.exists( pp );
	}

	/* get a File by name */
	public inline function file(name : String):File {
		return new File((path.absolute?'/':'')+path + name);
	}

	/* get a Dir by name */
	public inline function dir(name:String, create:Bool=false):Directory {
		return new Directory((path.absolute?'/':'')+(path + name), create);
	}

	/* iterate over [this] Directory's entries */
	public inline function iterator():DirIter {
		return new DirIter( this );
	}

	/* iterate over the entire directory-tree descending from [this] Dir */
	public function walk(f : FSEntry -> Void):Void {
		for (e in this) {
			switch ( e.type ) {
				case File(_):
					f( e );

				case Folder( dir ):
					f( e );
					dir.walk( f );
			}
		}
	}

	/* walk [this] Directory, and gather File objects */
	public function gather(?tester : File -> Bool):Array<File> {
		var results:Array<File> = new Array();

		/* for every entry in [this] Directory */
		for (e in entries) {
			switch ( e.type ) {
				/* if that entry is a File */
				case File( f ):
					/* if no tester was provided */
					if (tester == null) {
						results.push( f );
					}

					/* if a tester was provided */
					else {
						if (tester( f ))
							results.push( f );
					}

				/* if that entry is a Directory */
				case Folder( d ):
					var sub = d.gather( tester );
					results = results.concat( sub );
			}
		}

		return results;
	}

	/**
	  * search [this] Directory with GlobStar
	  */
	public function search(pattern:GlobStar, recursive:Bool=false):Array<File> {
		if ( !recursive ) {
			var results:Array<File> = new Array();
			for (e in entries) {
				if (e.isFile() && pattern.test( e.path )) {
					results.push(e.file());
				}
			}
			return results;
		}
		else {
			return gather(function(f : File):Bool {
				return pattern.test( f.path );
			});
		}
	}

	/* delete [this] Directory */
	public function delete(force:Bool = false):Void {
		if ( !force ) {
			Fs.deleteDirectory(path.toString());
		}
		else {
			Fs.deleteDirectory(path.toString());
		}
	}

	/* move [this] Directory */
	public function rename(npath : Path):Void {
		Fs.rename(path.toString(), npath.toString());
		_path = npath;
	}

	public function toString():String {
		return 'Directory($path)';
	}

/* === Computed Instance Fields === */

	/* the path to this Dir */
	public var path(get, never):Path;
	private inline function get_path():Path return _path;

	/* whether [this] Directory exists */
	public var exists(get, never):Bool;
	private inline function get_exists():Bool return Fs.exists(path.toString());

	/* all sub-paths of the Path to [this] */
	public var subpaths(get, never):Array<Path>;
	private function get_subpaths():Array<Path> {
		return readDirectory( path.str ).map( Path.fromString ).map(function(sp : Path) {
			sp.directory = path;
			return sp;
		});
	}

	/* the entries of [this] Folder */
	public var entries(get, never):Array<FSEntry>;
	private function get_entries():Array<FSEntry> {
		return subpaths.map( FSEntry.fromPath );
	}

/* === Instance Fields === */

	private var _path : Path;
}

class DirIter {
	/* Constructor Function */
	public inline function new(cd : CDirectory):Void {
		pp = new Path(cd.path.toString());
		ei = readDirectory( pp.str ).iterator();
	}

/* === Instance Methods === */

	public inline function hasNext():Bool return ei.hasNext();
	
	/* get the next entry */
	public function next():FSEntry {
		var epath:Path = (pp + ei.next());
		return FSEntry.fromPath( epath );
	}

	private var ei : Iterator<String>;
	private var pp : Path;
}
