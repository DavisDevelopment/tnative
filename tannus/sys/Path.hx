package tannus.sys;

using StringTools;
using Lambda;

@:access(haxe.io.Path)
abstract Path (String) from String to String {
	/* Constructor */
	public inline function new(s : String):Void {
		this = s;//.replace('~', '/home/$un/');
	}

/* === Instance Methods === */

	/**
	  * "normalized" version of [this] Path
	  */
	public inline function normalize():Path {
		var res:Path = (P.normalize(this));
		res = res.str.replace('~', '/home/$un');
		res = P.normalize(res);
		return res;
	}

/* === Instance Fields === */

	/**
	  * The directory name of [this] Path
	  */
	public var directory(get, set):Path;
	private inline function get_directory():Path {
		return P.directory(this);
	}
	private inline function set_directory(nd : Path):Path {
		this = (nd + name);
		return directory;
	}

	/**
	  * Whether [this] Path is the "root" directory
	  */
	public var root(get, never):Bool;
	private inline function get_root():Bool {
		return (directory == '');
	}

	/**
	  * The name of file referred to by [this] Path
	  */
	public var name(get, never):String;
	private inline function get_name():String {
		return P.withoutDirectory(this);
	}

	/**
	  * The base filename of [this] Path
	  */
	public var basename(get, set):String;
	private inline function get_basename():String {
		return P.withoutExtension(name);
	}
	private inline function set_basename(v : String):String {
		var d:String = directory;
		var e:String = extension;
		this = (d + '/' + v + (e == null?'':e));
		this = normalize().str;
		return basename;
	}

	/**
	  * The extension-name (if any) of [this] Path
	  */
	public var extension(get, set):Null<String>;
	private inline function get_extension():Null<String> {
		return P.extension(this);
	}
	private inline function set_extension(ns : Null<String>):Null<String> {
		if (ns != null) {
			this = (this.substr(0, this.lastIndexOf('.')) + '.$ns');
		} else {
			this = (this.substr(this.lastIndexOf('.') + 1));
		}
		return extension;
	}

	/**
	  * Whether [this] Path is an absolute one
	  */
	public var absolute(get, never):Bool;
	private inline function get_absolute():Bool {
		return P.isAbsolute(this);
	}
	
	/**
	  * An Array of all segments of [this] Path
	  */
	public var pieces(get, set):Array<String>;
	private inline function get_pieces():Array<String> {
		return (this.replace('\\', '/').split('/'));
	}
	private inline function set_pieces(a : Array<String>):Array<String> {
		this = P.join(a);
		return pieces;
	}

/* === Instance Methods === */

	/**
	  * Join [this] Path with another
	  */
	@:op(A + B)
	public inline function join(other : Path):Path {
		return P.join([this, other]);
	}

	/**
	  * Obtain a Path which is [other] relative to [this]
	  */
	public function resolve(other : Path):Path {
		if (!absolute) {
			throw 'PathError: Cannot resolve a relative Path by another relative Path; One of them must be absolute!';
		} else {
			var mine = pieces;
			var yours = other.pieces;

			for (s in yours) {
				if (s == '.' || s == '') 
					continue;

				else if (s == '..') 
					mine.pop();

				else 
					mine.push(s);
			}
			var res:Path = (P.join( mine ));
			/* Now, ensure that [res] is still an absolute Path */
			if (!res.absolute)
				res = ('/' + res);

			res = res.normalize();
			return res;
		}
	}

	/**
	  * Reference to [this] Path as a String
	  */
	public var str(get, never):String;
	private inline function get_str() return this;

	private static var os(get, never):String;
	private static inline function get_os() {
		#if (js || flash || as3)
			return 'web';
		#else
			return Sys.systemName().toLowerCase();
		#end
	}

	private static var un:String = {tannus.internal.CompileTime.getUserName();};
}

private typedef P = haxe.io.Path;
