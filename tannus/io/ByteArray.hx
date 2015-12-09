package tannus.io;

import tannus.io.Byte;

import haxe.io.Bytes;

@:forward
abstract ByteArray (Binary) from Binary to Binary {
	/* Constructor Function */
	private inline function new(bin : Binary):Void {
		this = bin;
	}

/* === Instance Methods === */

	@:arrayAccess
	public inline function get(i:Int):Byte return this.get(i);
	@:arrayAccess
	public inline function set(i:Int, v:Byte):Byte return this.set(i, v);

	@:to
	public inline function toString():String return this.toString();

	@:to
	public inline function toBytes():haxe.io.Bytes return this.toBytes();

	@:to
	public inline function toBase():BinaryData return this.getData();

	@:to
	public inline function toArray():Array<Byte> return this.toArray();

	@:op(A += B)
	public inline function expand(other : ByteArray):ByteArray {
		return this.append( other );
	}

	@:op(A + B)
	public inline function concat(other : ByteArray):ByteArray {
		return this.concat( other );
	}

	@:op(A == B)
	public inline function equals(o : ByteArray):Bool {
		return this.equals(o);
	}

/* === Static Methods === */

	/* build a new Binary of the given size */
	public static inline function alloc(size : Int):ByteArray {
		return new ByteArray(cast BinaryImpl.alloc( size ));
	}

	/* build a Binary from some BinaryData */
	@:from
	public static inline function ofData(d : BinaryData):ByteArray {
		return new ByteArray(cast BinaryImpl.ofData( d ));
	}

	/* build a Binary from a String */
	@:from
	public static inline function ofString(s : String):ByteArray {
		return new ByteArray(cast BinaryImpl.ofString( s ));
	}

	/* build a Binary from haxe.io.Bytes */
	@:from
	public static inline function fromBytes(b : Bytes):ByteArray {
		return new ByteArray(cast BinaryImpl.fromBytes( b ));
	}

	/* build a Binary from a base-64 encoded String */
	public static inline function fromBase64(s : String):ByteArray {
		return new ByteArray(cast BinaryImpl.fromBase64( s ));
	}
}

#if python
	typedef BinaryImpl = tannus.io.impl.PythonBinary;
#elseif js
	typedef BinaryImpl = tannus.io.impl.JavaScriptBinary;
#else
	typedef BinaryImpl = tannus.io.impl.GenericBinary;
#end
