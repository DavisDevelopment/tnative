package tannus.node;

import js.html.ArrayBuffer;

@:native('Buffer')
extern class Buffer implements ArrayAccess<Int> {
	/**
	  * Constructor Function
	  */
	@:overload(function(str:String, ?encoding:String):Void {})
	@:overload(function(arr : Array<Int>):Void {})
	function new(size : Int):Void;

/* === Instance Fields === */

    public var buffer : ArrayBuffer;
	var length(default, never) : Int;
	var INSPECT_MAX_BYTES : Int;

/* === Instance Methods === */

	/* Copy Data from one Buffer to another */
	function copy(target:Buffer, tstart:Int, srcstart:Int, srcend:Int):Void;

	/* Get a sub-buffer */
	function slice(start:Int, end:Int):Buffer;

	/* Append some data to [this] Buffer */
	function write(s:String, ?offset:Int, ?length:Int, ?enc:String):Int;

	/* Convert [this] Buffer to a String */
	function toString(enc:String, ?start:Int, ?end:Int):String;

	/* Fill [this] Buffer with a specified value */
	function fill(value:Float, offset:Int, ?end:Int):Void;

	/* Determine whether [this] Buffer and [other] Buffer have the same Bytes */
	function compare(other : Buffer):Bool;

	/* == Lower-Level Reading Methods == */
	function readUInt8(offset:Int, ?noAssert:Bool):Int;
	function readUInt16LE(offset:Int, ?noAssert:Bool):Int;
	function readUInt16BE(offset:Int, ?noAssert:Bool):Int;
	function readUInt32LE(offset:Int, ?noAssert:Bool):Int;
	function readUInt32BE(offset:Int, ?noAssert:Bool):Int;

	function readInt8(offset:Int, ?noAssert:Bool):Int;
	function readInt16LE(offset:Int, ?noAssert:Bool):Int;
	function readInt16BE(offset:Int, ?noAssert:Bool):Int;
	function readInt32LE(offset:Int, ?noAssert:Bool):Int;
	function readInt32BE(offset:Int, ?noAssert:Bool):Int;

	function readFloatLE(offset:Int, ?noAssert:Bool):Float;
	function readFloatBE(offset:Int, ?noAssert:Bool):Float;
	function readDoubleLE(offset:Int, ?noAssert:Bool):Float;
	function readDoubleBE(offset:Int, ?noAssert:Bool):Float;

	function writeUInt8(value:Int, offset:Int, ?noAssert:Bool):Void;
	function writeUInt16LE(value:Int, offset:Int, ?noAssert:Bool):Void;
	function writeUInt16BE(value:Int, offset:Int, ?noAssert:Bool):Void;
	function writeUInt32LE(value:Int, offset:Int, ?noAssert:Bool):Void;
	function writeUInt32BE(value:Int, offset:Int, ?noAssert:Bool):Void;

	function writeInt8(value:Int,offset:Int,?noAssert:Bool):Void;
	function writeInt16LE(value:Int,offset:Int,?noAssert:Bool):Void;
	function writeInt16BE(value:Int,offset:Int,?noAssert:Bool):Void;
	function writeInt32LE(value:Int,offset:Int,?noAssert:Bool):Void;
	function writeInt32BE(value:Int,offset:Int,?noAssert:Bool):Void;

	function writeFloatLE(value:Float,offset:Int,?noAssert:Bool):Void;
	function writeFloatBE(value:Float,offset:Int,?noAssert:Bool):Void;
	function writeDoubleLE(value:Float,offset:Int,?noAssert:Bool):Void;
	function writeDoubleBE(value:Float,offset:Int,?noAssert:Bool):Void;

/* === Static Methods === */

	/* Test whether a given value [o] is a Buffer */
	static function isBuffer(o:Dynamic):Bool;
	static function isEncoding(enc : String):Bool;

	static function byteLength(s:String,?enc:String):Int;
	static function concat(list:Array<Buffer>, ?totalLength:Float):Buffer;

    @:overload(function(arrayBuffer:js.html.ArrayBuffer, ?byteOffset:Int, ?length:Int):Buffer {})
    @:overload(function(buffer:Buffer):Buffer {})
    @:overload(function(string:String, encoding:String):Buffer {})
	static function from(array : Array<Int>):Buffer;
}
