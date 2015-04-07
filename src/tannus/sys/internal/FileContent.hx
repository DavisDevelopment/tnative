package tannus.sys.internal;

import tannus.io.Ptr;
import tannus.io.ByteArray;

import tannus.sys.File;

/**
  * Abstract class which wraps around a File instance to allow dope stuff
  */
abstract FileContent (Ptr<File>) {
	/* Constructor Function */
	public inline function new(f : Ptr<File>):Void {
		this = f;
	}

	/**
	  * internal reference to [this] as a File
	  */
	private var f(get, never):File;
	private inline function get_f():File {
		return (this.value);
	}

/* === Operators === */

	/**
	  * Add/Assign-style write
	  */
	@:op(A += B)
	public inline function append(data : ByteArray):Void {
		f.append( data );
	}

/* === Type Casting === */

	/**
	  * To ByteArray
	  */
	@:to
	public inline function toByteArray():ByteArray {
		return f.read();
	}

	/**
	  * To String
	  */
	@:to
	public inline function toString():String {
		return f.read();
	}

}
