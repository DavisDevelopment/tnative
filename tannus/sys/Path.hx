package tannus.sys;

import haxe.io.Path in P;

import tannus.io.ByteArray;
import tannus.sys.Mimes;
import tannus.sys.Mime;

using StringTools;
using Lambda;
using tannus.ds.StringUtils;
using tannus.ds.ArrayTools;

@:forward
@:access( haxe.io.Path )
abstract Path (CPath) from CPath to CPath {
	/* Constructor Function */
	public inline function new(s : String):Void {
		this = new CPath( s );
	}

/* === Operator Overloads === */

	/* get the sum of two Paths */
	public static inline function sum(x:Path, y:Path):Path {
		return new Path(CPath.join([x.toString(), y.toString()]));
	}

	/* get the sum of [this] Path and [other] */
	@:op(A + B)
	public inline function plusPath(other : Path):Path return this.plusPath(other);

	@:op(A + B)
	public inline function plusString(other : String):Path return this.plusString(other);

/* === Implicit Casting Methods === */

	/* to String */
	@:to
	public inline function toString():String {
		return this.toString();
	}

	/* from String */
	@:from
	public static function fromString(s : String):Path {
		return new Path( s );
	}

	/* to ByteArray */
	@:to
	public inline function toByteArray():ByteArray {
		return ByteArray.ofString(toString());
	}

	/* from ByteArray */
	@:from
	public static inline function fromByteArray(b : ByteArray):Path {
		return fromString(b.toString());
	}

    /* from Array<String> */
	@:from
	public static inline function fromPieces(bits : Array<String>):Path {
	    return CPath.sjoin( bits );
	}
}
