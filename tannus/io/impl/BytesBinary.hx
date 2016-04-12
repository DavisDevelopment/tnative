package tannus.io.impl;

import haxe.io.Bytes;
import tannus.io.Byte;
import tannus.io.BinaryData;

using tannus.ds.ArrayTools;

class BytesBinary extends Binary {
	/* Constructor Function */
	public function new(size:Int, b:BinaryData):Void {
		super(size, b);
	}

/* === Instance Methods === */

	/* get the Byte at the given index */
	override public function get(i : Int):Byte {
		super.get( i );
		return b.get( i );
	}

	/* set the Byte at the given index */
	override public function set(i:Int, v:Byte):Byte {
		super.set(i, v);
		b.set(i, v);
		return b.get( i );
	}

	/* get a subset of [this] */
	override public function sub(index:Int, size:Int):Binary {
		var sub_b:Bytes = Bytes.alloc( size );
		sub_b.blit(0, b, index, size);
		return new BytesBinary(size, sub_b);
	}

	/* copy data from [src] onto [this] */
	override public function blit(index:Int, src:Binary, srcIndex:Int, len:Int):Void {
		b.blit(index, src.getData(), srcIndex, len);
	}

	/* get a String */
	override public function getString(i:Int, len:Int):String {
		return b.getString(i, len);
	}

	/* create and return the sub of [this] and [other] */
	override public function concat(other : Binary):Binary {
		var ob:Bytes = other.getData();
		var sum_len:Int = (b.length + ob.length);
		var sum_b:Bytes = Bytes.alloc( sum_len );
		sum_b.blit(0, b, 0, b.length);
		sum_b.blit(b.length, ob, 0, ob.length);
		return new BytesBinary(sum_len, sum_b);
	}

	/* resize [this] data, in place */
	override public function resize(size : Int):Void {
		super.resize( size );

		if (size < length) {
			b = sub(0, size).b;
			_length = b.length;
		}
		else {
			var _b = b;
			b = Bytes.alloc( size );
			b.fill(0, size, 0);
			b.blit(0, _b, 0, _b.length);
			_length = b.length;
		}
	}

	/* create and return a copy of [this] */
	override public function copy():Binary {
		var cb = Bytes.alloc( b.length );
		cb.blit(0, b, 0, b.length);
		return new BytesBinary(length, cb);
	}

	/* write a String to [this] */
	override public function writeString(s : String):Void {
		write(ofString( s ));
	}

	/* convert to a haxe.io.Bytes object */
	override public function toBytes():Bytes {
		return copy().getData();
	}

/* === Static Methods === */

	/* create an empty Binary, of the given size */
	public static function alloc(size : Int):BytesBinary {
		return new BytesBinary(size, Bytes.alloc( size ));
	}

	/* create a BytesBinary for the given Bytes */
	public static function ofData(data : BinaryData):BytesBinary {
		return new BytesBinary(data.length, data);
	}
	public static function fromBytes(b : Bytes):BytesBinary return ofData( b );

	/* create a BytesBinary from a String */
	public static function ofString(s : String):BytesBinary {
		return new BytesBinary(s.length, Bytes.ofString( s ));
	}

	/* create a BytesBinary from a base64-encoded String */
	public static function fromBase64(s : String):BytesBinary {
		return ofData(haxe.crypto.Base64.decode( s ));
	}
}
