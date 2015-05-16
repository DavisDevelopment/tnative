package tannus.sys;

import tannus.sys.Path;
import tannus.sys.File;
import tannus.sys.FileSystem;
import tannus.sys.Directory;

import haxe.macro.Expr;

abstract FSEntry (FSEntryType) {
	/* Constructor Function */
	public inline function new(et : FSEntryType):Void {
		this = et;
	}

	/**
	  * [this] as an FSEntryType
	  */
	public var type(get, never):FSEntryType;
	private inline function get_type() return this;

	/**
	  * The Path to [this] Entry
	  */
	public var path(get, never):Path;
	private function get_path():Path {
		return switchType( f.path );
	}

	/**
	  * Rename [this] Entry
	  */
	public inline function rename(ndir : Path):Void {
		switchType(f.rename( ndir ));
	}

	/**
	  * Delete [this] Entry
	  */
	public inline function delete():Void {
		switchType(f.delete());
	}

/* === Implicit Casting === */

	/* From Path */
	@:from
	public static inline function fromPath(p : Path):FSEntry {
		if (FileSystem.exists(p)) {
			if (FileSystem.isDirectory( p ))
				return new FSEntry(Folder( p ));
			else
				return new FSEntry(File( p ));
		} else throw 'IOError: Cannot create FSEntry instance for Path which does not exist';
	}

	/* From String */
	public static inline function fromString(s : String):FSEntry {
		return fromPath( s );
	}

	public macro function switchType(self:ExprOf<FSEntry>, f:Expr, oth:Array<Expr>) {
		var d:Expr = oth.shift();
		var ff:Expr = oth.shift();
		var dd:Expr = oth.shift();

		switch ([f, d, ff, dd]) {
			case [fid, null, null, null]:
				ff = fid;
				dd = fid;
				f = (macro f);
				d = (macro f);

			case [file, directory, null, null]:
				f = (macro f);
				d = (macro f);
				ff = file;
				dd = directory;

			case [name, fH, dH, null]:
				f = name;
				d = name;
				ff = fH;
				dd = dH;
		}

		return macro switch ($self.type) {
			case File( $f ):
				$ff;

			case Folder( $d ):
				$dd;
		};
	}
}

enum FSEntryType {
	/* File Entry */
	File(f : File);

	/* Folder Entry */
	Folder(d : Directory);
}
