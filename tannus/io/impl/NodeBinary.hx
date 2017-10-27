package tannus.io.impl;

import tannus.io.Byte;
import js.html.ArrayBuffer;
import js.html.DataView;
import js.html.Uint8Array;

import tannus.node.Buffer;

using Lambda;
using tannus.ds.ArrayTools;

#if (js && node)
@:expose('tannus.io.ByteArray')
#end
@:expose('Binary')
class NodeBinary extends Binary {
	/* Constructor Function */
	public function new(size:Int, data:Buffer):Void {
		super(size, data);
	}

/* === Instance Methods === */

	/**
	  * Get a Byte
	  */
	override public function get(index : Int):Byte {
		super.get( index );
		//return buffer[ index ];
		return buffer.readUInt8(index);
	}

	/**
	  * Set a Byte
	  */
	override public function set(index:Int, value:Byte):Byte {
		super.set(index, value);
		return (buffer[index] = value);
	}

	override function fill(c:Byte, ?offset, ?end) {
	    b.fill(c, offset, end);
	}
	override function copy():Binary {
	    return NodeBinary.ofData(Buffer.from( b ));
	}
	override function equals(o : Binary):Bool {
	    return (b.compare( o.b ));
	}

	/**
	  * Get a subset of [this] data
	  */
	override public function sub(index:Int, size:Int):Binary {
		var subdata:Buffer = buffer.slice(index, (index + size));
		return new NodeBinary(size, subdata);
	}

	/**
	  * get a 'slice' of [this] data
	  */
	override public function slice(start:Int, ?end:Int):Binary {
		if (end == null) {
			end = length;
		}
		return new NodeBinary((end - start), buffer.slice(start, end));
	}

	/**
	  * copy the given chunk of data onto [this] one
	  */
	override public function blit(index:Int, src:Binary, srcIndex:Int, size:Int):Void {
	    var end = (srcIndex + size);
	    src.b.copy(b, index, srcIndex, end);
		//for (i in 0...size) {
			//set((index + i), src.get(srcIndex + i));
		//}
	}

	/**
	  * get some of [this] data as a String
	  */
	override public function getString(index:Int, size:Int):String {
		return buffer.toString('utf8', index, (index + size));
	}

	/**
	  * resize [this] data
	  */
	override public function resize(size : Int):Void {
		if (size < length) {
			setData(b = b.slice(0, size));
		}
		else {
			var bigger = alloc( size );
			bigger.blit(0, this, 0, length);
			setData( bigger.b );
		}
	}

	/**
	  * return the sum of [this] data and another
	  */
	override public function concat(other : ByteArray):ByteArray {
		var sum:NodeBinary = alloc(length + other.length);
		b.copy(sum.b, 0, 0, length);
		other.b.copy(sum.b, length, 0, other.length);
		return sum;
	}

	/**
	  * reassign the underlying data
	  */
	override private function setData(data : BinaryData):Void {
		b = data;
		_length = data.length;
	}

	override function toBytes() {
	    return haxe.io.Bytes.ofData(new js.html.Uint8Array(untyped buffer).buffer);
	}
	override function base64Encode() {
	    return b.toString('base64');
	}

/* === Computed Instance Fields === */

	/* the underlying Buffer */
	private var buffer(get, never):Buffer;
	private inline function get_buffer():Buffer return b;

/* === Static Methods === */

	/**
	  * Create and return a new Binary of the given size
	  */
	public static inline function alloc(size : Int):NodeBinary {
		return new NodeBinary(size, new Buffer( size ));
	}

	/**
	  * Create and return a new Binary from the given BinaryData
	  */
	public static inline function ofData(data : BinaryData):NodeBinary {
		return new NodeBinary(data.length, Buffer.from( data ));
	}

	/**
	  * create and return a new Binary, from a String
	  */
	public static inline function ofString(s : String):NodeBinary {
		return new NodeBinary(s.length, new Buffer( s ));
	}

	/**
	  * create and return a new Binary, from a haxe.io.Bytes object
	  */
	public static inline function fromBytes(b : haxe.io.Bytes):NodeBinary {
	    return ofData(Buffer.from(b.getData().slice(0)));
	}
	
	/**
	  * create and return a new Binary, from Base64 data
	  */
	public static inline function fromBase64(s : String):NodeBinary {
		//return fromBytes(haxe.crypto.Base64.decode( s ));
		return ofData(Buffer.from(s, 'base64'));
	}
}
