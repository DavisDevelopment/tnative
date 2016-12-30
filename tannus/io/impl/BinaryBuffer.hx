package tannus.io.impl;

import haxe.io.Bytes;
import tannus.io.*;
import tannus.io.BinaryData;

using tannus.ds.ArrayTools;

class BinaryBuffer {
	/* Constructor Function */
	public function new():Void {

	}

/* === Instance Methods === */

	public function add(data : ByteArray):Void {
		return ;
	}

	public function addByte(n : Byte):Void {
		return ;
	}
	public function addByteArray(data:ByteArray, pos:Int, len:Int):Void {
		return ;
	}
	public function addDouble(n : Float):Void {
		return ;
	}
	public function addFloat(n : Float):Void {
		return ;
	}
	public function addInt32(n : Int):Void {
		return ;
	}
	//public function addInt64(n : Int):Void {
		//return ;
	//}
	public function addString(s : String):Void {
		return ;
	}
	public function getByteArray():ByteArray {
		return new ByteArray( 0 );
	}

/* === Instance Fields === */

	public var length(get, never):Int;
	private function get_length():Int return 0;
}
