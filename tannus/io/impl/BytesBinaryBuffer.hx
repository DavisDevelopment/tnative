package tannus.io.impl;

import haxe.io.Bytes;
import haxe.io.BytesBuffer;

import tannus.io.*;
import tannus.io.BinaryData;

using tannus.ds.ArrayTools;

class BytesBinaryBuffer extends BinaryBuffer {
	/* Constructor Function */
	public function new():Void {
		super();

		b = new BytesBuffer();
	}

/* === Instance Methods === */

	override function add(data : ByteArray):Void {
		b.add(data.toBytes());
	}

	override function addByte(n : Byte):Void {
		b.addByte(n.toInt());
	}
	override function addByteArray(data:ByteArray, pos:Int, len:Int):Void {
		var bytes = data.toBytes();
		b.addBytes(bytes, pos, len);
	}
	override function addDouble(n : Float):Void {
		b.addDouble( n );
	}
	override function addFloat(n : Float):Void {
		b.addFloat( n );
	}
	override function addInt32(n : Int):Void {
		b.addInt32( n );
	}
	//override function addInt64(n : Int):Void {
		
	//}
	override function addString(s : String):Void {
		b.addString( s );
	}
	override function getByteArray():ByteArray {
		return ByteArray.fromBytes(b.getBytes());
	}

/* === Instance Fields === */

	override function get_length():Int return b.length;

	private var b : BytesBuffer;
}
