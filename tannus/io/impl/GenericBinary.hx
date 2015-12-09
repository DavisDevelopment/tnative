package tannus.io.impl;

import tannus.io.Byte;
import tannus.io.BinaryData;

using tannus.ds.ArrayTools;

class GenericBinary extends Binary {
	/* Constructor Function */
	public function new(length:Int, b:BinaryData):Void {
		super(length, b);
	}

	/* get the value at [i] */
	override public function get(i : Int):Byte {
		super.get( i );
		return new Byte(untyped b[i]);
	}

	/* set the value at [i] */
	override public function set(i:Int, v:Byte):Byte {
		super.set(i, v);
		return untyped (b[i] = v.asint);
	}

	/* get a sub-binary */
	override public function sub(index:Int, size:Int):Binary {
		return new GenericBinary(size, b.slice(index, (index+size)));
	}

	/* copy another chunk of data onto [this] one */
	override public function blit(index:Int, src:Binary, srcIndex:Int, size:Int):Void {
		for (i in 0...size) {
			set((index + i), src.get(srcIndex + i));
		}
	}

	/* get some string data */
	override public function getString(index:Int, len:Int):String {
		var s:String = '';
		var b = b;
		for (i in 0...len) {
			s += get(i + index);
		}
		return s;
	}

	/* resize [this] data */
	override public function resize(size : Int):Void {
		super.resize( size );

		if (size < length) {
			b = b.slice(0, size);
			_length = size;
		}
		else {
			b = b.concat([0].times(size - length));
			_length = size;
		}
	}

	/* concatenate [this] data with another */
	override public function concat(other : ByteArray):ByteArray {
		var target:GenericBinary = alloc(length + other.length);
		target.blit(0, this, 0, length);
		target.blit(length, other, 0, other.length);
		return target;
	}

	/* create and return a copy of [this] */
	override public function copy():Binary {
		return ofData(b.copy());
	}

	/* write a String to [this] data */
	override public function writeString(s : String):Void {
		write(ofString( s ));
	}

	/* === Static Methods === */

	/* create an empty Binary of the specified size */
	public static inline function alloc(size : Int):GenericBinary {
		return new GenericBinary(size, [0].times(size));
	}

	/* create a new Binary around the given data */
	public static inline function ofData(b : BinaryData):GenericBinary {
		return new GenericBinary(b.length, b);
	}

	/* create a Binary from the given String */
	public static function ofString(s : String):GenericBinary {
		var bits:Array<Int> = new Array();
		for (i in 0...s.length)
			bits.push(s.charCodeAt(i));
		return ofData( bits );
	}

	/* create a Binary from a haxe.io.Bytes instance */
	public static function fromBytes(b : haxe.io.Bytes):GenericBinary {
		var c:GenericBinary = alloc( b.length );
		for (i in 0...b.length)
			c.set(i, b.get(i));
		return c;
	}

	/* create a Binary from a base-64 encoded String */
	public static function fromBase64(s : String):GenericBinary {
		return fromBytes(haxe.crypto.Base64.decode(s));
	}
}
