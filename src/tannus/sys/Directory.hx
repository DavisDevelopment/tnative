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
			if (!isDirectory(this)) throw 'IOError: $p is not a Directory!';
		} else {
			if (create) 
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
		var rnames:Array<Path> = FileSystem.readDirectory(this);
		var elist:Array<FSEntry> = new Array();
		for (i in 0...rnames.length) {
			rnames[i].directory = this;
			elist.push( rnames[i] );
		}
		return elist;
	}
}
