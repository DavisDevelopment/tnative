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
	  * The name of [this] Entry
	  */
	public var name(get, never):String;
	private inline function get_name():String {
		return (path.name);
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

	/**
	  * Get [this] Entry as a File, if possible
	  */
	@:to
	public function file():File {
		switch (type) {
			case File( f ):
				return f;

			case Folder( d ):
				throw 'IOError: Cannot cast a Directory to a File!';
		}
	}

	/**
	  * Check if [this] Entry is a File
	  */
	public function isFile():Bool {
		return switchType(f, d, true, false);
	}

	/**
	  * Check if [this] Entry is a Folder
	  */
	public function isDirectory():Bool {
		return switchType(f, d, false, true);
	}
	
	/**
	  * Get [this] Entry as a Directory, if possible
	  */
	@:to
	public function folder():Directory {
		switch ( type ) {
			case File( f ):
				throw 'IOError: Cannot cast a File to a Directory!';
				
			case Folder( d ):
				return d;
		}
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
	@:from
	public static inline function fromString(s : String):FSEntry {
		return fromPath( s );
	}

	/**
	  * macro-method for performing actions based on the type of entry [this] is
	  */
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
