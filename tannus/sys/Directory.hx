package tannus.sys;

import tannus.sys.Path;
import tannus.sys.FileSystem.*;
import tannus.sys.FileSystem in Fs;
import tannus.sys.FSEntry;

abstract Directory (Path) from Path {
	/* Constructor Function */
	public inline function new(p:Path, ?create:Bool=false):Void {
		this = p;
		if (Fs.exists(this)) {
			if (!isDirectory(this)) 
				throw 'IOError: $p is not a Directory!';
		} 
		else {
			if ( create ) 
				createDirectory( this );
			else
				throw 'IOError: $p is not a File or a Directory!';
		}
	}

/* === Instance Methods === */

	/**
	  * Obtain an Entry by name
	  */
	@:arrayAccess
	public inline function get(name : String):Null<FSEntry> {
		var entry:FSEntry = name;
		var canRet:Bool = entry.switchType(f.exists);
		return (canRet ? entry : null);
	}

	/**
	  * Obtain a File by name
	  */
	public inline function file(name : String):File {
		var f:File = (path + name);
		return f;
	}

	/**
	  * Obtain a Directory by name
	  */
	public inline function dir(name:String, ?createIfNecessary:Bool):Directory {
		return new Directory((path + name), createIfNecessary);
	}

	/**
	  * Iterate over [this] Directory
	  */
	public inline function iterator():Iterator<FSEntry> {
		var el = entries;
		return el.iterator();
	}

	/**
	  * Iterate over every FSEntry in [this] Directory, or ANY subdirectory of it
	  */
	public function walk(func : FSEntry->Void):Void {
		for (e in entries) {
			switch (e.type) {
				case File( f ):
					func( e );

				case Folder( d ):
					func( e );
					d.walk( func );
			}
		}
	}

	/**
	  * Recursively walk [this] Directory
	  */
	public function walkRecursive(?tester : File->Bool):Array<File> {
		var results:Array<File> = new Array();

		/* for every entry in [this] Directory */
		for (e in entries) {
			switch (e.type) {
				/* if that entry is a File */
				case File( f ):
					/* if no tester was provided */
					if (tester == null) {
						results.push( f );
					}

					/* if a tester was provided */
					else {
						if (tester(f))
							results.push( f );
					}

				/* if that entry is a Directory */
				case Folder( d ):
					results = results.concat(d.walkRecursive(tester));
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
			return walkRecursive(function(f : File):Bool {
				return pattern.test( f.path );
			});
		}
	}

	/**
	  * Rename [this] Directory (Move it)
	  */
	public inline function rename(ndir : String):Void {
		Fs.rename(this, ndir);
	}

	/**
	  * Delete [this] Directory
	  ----
	  * @param [force] - if true, will traverse the Directory, deleting all of it's sub-entries
	  */
	public function delete(?force:Bool = false):Void {
		if (!force) {
			deleteDirectory( this );
		}
		else {
			walk(function(entry) entry.switchType(f.delete(), f.delete(true)));
		}
	}

/* === Instance Fields === */

	/**
	  * The Path to [this] Directory
	  */
	public var path(get, never):Path;
	private inline function get_path() return this;

	/**
	  * Whether [this] Path points to a valid Directory
	  */ 
	public var exists(get, never):Bool;
	private inline function get_exists():Bool 
		return Fs.exists( path );

	/**
	  * All files/folders within [this] Directory
	  */
	public var entries(get, never):Array<FSEntry>;
	private function get_entries():Array<FSEntry> {
		var rnames:Array<Path> = [for (s in FileSystem.readDirectory(this)) new Path(s)];
		var elist:Array<FSEntry> = new Array();
		for (i in 0...rnames.length) {
			rnames[i].directory = this;
			elist.push( rnames[i] );
		}
		return elist;
	}
}
