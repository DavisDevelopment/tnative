package tannus.io;

import haxe.io.Bytes;
import haxe.io.BytesData;

import tannus.io.Byte;

#if (js && !node)

import js.html.ArrayBuffer;

#elseif python

import python.Bytearray;

#end

@:forward
abstract Buffer (CBuffer) from CBuffer {
	/* Constructor Function */
	public inline function new(bits : Bytes):Void {
		this = new CBuffer(bits);
	}

/* === Casting === */

	/* to String */
	@:to
	public inline function toString() return this.toString();

	/* from String */
	@:from
	public static function fromString(s : String):Buffer {
		var b:Buffer = Buffer.alloc(s.length);
		for (c in s.split(''))
			b.writeByte( c );
		return b;
	}

	#if (js && !node)
		/* to ArrayBuffer */
		@:to
		public inline function toArrayBuffer():ArrayBuffer {
			return (untyped this.getData());
		}
	#end

/* ==== Creation === */

	/* Alloc */
	public static inline function alloc(size : Int):Buffer {
		return cast CBuffer.alloc(size);
	}
}

class CBuffer {
	/* Constructor Function */
	public function new(byts : Bytes):Void {
		bytes = byts;
		cursor = 0;
	}

/* === Instance Methods === */

	/**
	  * Move the cursor to [pos]
	  */
	public function goto(offset : Int):Void {
		if (offset < 0) {
			cursor = (length - (offset * -1));
		}
		else {
			cursor = offset;
		}
	}

	/**
	  * Move ahead by [d] bytes
	  */
	private function adv(d:Int=1):Int {
		var _r = cursor;
		cursor += d;
		return _r;
	}

	/**
	  * Blit another Buffer onto [this] one
	  */
	public function blit(pos:Int, src:Buffer, srcpos:Int, len:Int):Void {
		bytes.blit(pos, src.bytes, srcpos, len);
	}

	/**
	  * Get a Slice of [this] Buffer
	  */
	public function slice(pos:Int, len:Int):Buffer {
		return new Buffer(bytes.sub(pos, len));
	}

/* === Reading Methods === */

	/**
	  * Read an Int
	  */
	public function readInt():Int {
		return bytes.get(adv());
	}

	/**
	  * Read a Byte
	  */
	public function readByte():Byte {
		return new Byte(readInt());
	}

	/* Read a Boolean Value */
	public function readBool():Bool {
		var i:Int = readInt();
		if (!(i == 0 || i == 1))
			throw 'InputMismatchError: Byte $i cannot be interpreted as a Boolean value!';
		else
			return (i == 1);
	}

	/**
	  * Read a Double
	  */
	public inline function readDouble():Float {
		return bytes.getDouble(adv(8));
	}

	/**
	  * Read a Float
	  */
	public inline function readFloat():Float {
		return bytes.getFloat(adv(4));
	}

	/**
	  * Read 32-bit Int
	  */
	public inline function readInt32():Int {
		return bytes.getInt32(adv(2));
	}

	/**
	  * Read 64-bit Int
	  */
	public inline function readInt64():haxe.Int64 {
		return bytes.getInt64(adv(3));
	}

	/**
	  * Read a String from [this] Buffer
	  */
	public inline function readString(len : Int):String {
		return bytes.getString(adv(len), len);
	}

/* === Writing Methods === */

	/**
	  * Write an Int
	  */
	public function writeInt(i : Int):Void {
		bytes.set(cursor++, i);
	}

	/* Write a Byte */
	public inline function writeByte(b : Byte):Void {
		writeInt(b.asint);
	}

	/* Write a Boolean */
	public inline function writeBool(v : Bool):Void {
		writeInt(v ? 1 : 0);
	}

	/* Write a Double */
	public inline function writeDouble(d : Float):Void {
		bytes.setDouble(adv(8), d);
	}

	/* Write a Float */
	public inline function writeFloat(f : Float):Void {
		bytes.setFloat(adv(4), f);
	}

	/* Write a 32-bit Int */
	public inline function writeInt32(i : Int):Void {
		bytes.setInt32(adv(2), i);
	}

	/* Write a 64-bit Int */
	public inline function writeInt64(i : haxe.Int64):Void {
		bytes.setInt64(adv(3), i);
	}

	/* Write a String to [this] Buffer */
	public inline function writeString(s : String):Void {
		bytes.blit(adv(s.length), Bytes.ofString(s), 0, s.length);
	}

/* === Conversion Methods === */

	/* To BytesData */
	public inline function getData():BytesData {
		return bytes.getData();
	}

	/* To String */
	public inline function toString():String {
		return bytes.toString();
	}

/* === Computed Instance Fields === */

	public var length(get, never):Int;
	private inline function get_length():Int return bytes.length;

/* === Instance Fields === */

	private var bytes : Bytes;
	private var cursor : Int;

/* === Static Methods === */

	/* Create a new Buffer of the specified size */
	public static function alloc(size : Int):CBuffer {
		return new CBuffer(Bytes.alloc(size));
	}
}
