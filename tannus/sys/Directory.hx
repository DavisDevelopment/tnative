package tannus.sys;

import tannus.sys.Path;
import tannus.sys.FileSystem.*;
import tannus.sys.FileSystem in Fs;
import tannus.sys.FSEntry;

using tannus.ds.StringUtils;
using tannus.ds.ArrayTools;

@:forward
abstract Directory (CDirectory) to CDirectory from CDirectory {
	/* Constructor Function */
	public inline function new(p:Path, create:Bool=false):Void {
		this = new CDirectory(p, create);
	}

/* === Instance Methods === */

	@:arrayAccess
	public inline function get(name : String):Null<FSEntry> return this.getEntry( name );

	@:from
	public static inline function fromPath(path : Path):Directory {
		return new Directory( path );
	}

	@:from
	public static inline function fromString(s : String):Directory {
		return new Directory(Path.fromString( s ));
	}
}
