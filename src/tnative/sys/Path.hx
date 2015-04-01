package tnative.sys;

using StringTools;
using Lambda;

abstract Path (String) from String to String {
	/* Constructor */
	public inline function new(s : String):Void {
		this = s;
	}

/* === Instance Fields === */

	/**
	  * The directory name of [this] Path
	  */
	public var directory(get, never):Path;
	private inline function get_directory():Path {
		return P.directory(this);
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
	public var basename(get, never):String;
	private inline function get_basename():String {
		return P.withoutExtension(name);
	}

	/**
	  * The extension-name (if any) of [this] Path
	  */
	public var extension(get, never):String;
	private inline function get_extension():String {
		return P.extension(this);
	}

	/**
	  * Whether [this] Path is an absolute one
	  */
	public var absolute(get, never):Bool;
	private inline function get_absolute():Bool {
		return P.isAbsolute(this);
	}

/* === Instance Methods === */

	/**
	  * Join [this] Path with another
	  */
	@:op(A + B)
	public inline function join(other : Path):Path {
		return P.join([this, other]);
	}
}

private typedef P = haxe.io.Path;
