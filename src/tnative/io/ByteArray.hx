package tnative.io;

/* "haxe" imports */
import haxe.io.Bytes;
import haxe.io.BytesData;

/* "gen" imports */
import tnative.io.Byte;

import tnative.math.Nums;

/* == Platform-Specific Imports == */

#if python
/* "python" Imports */
//import python.lib.Bytes;
//import python.lib.Tuple;
#end

using Lambda;

/**
  * Abstract Class representing an Array of Bytes as an Entity unto itself, such as the contents of a File
  */
@:forward(length, push, pop, shift, unshift, filter)
abstract ByteArray (Array<Byte>) {
	/* Constructor */
	public function new(?a : Array<Byte>):Void {
		this = (a != null ? a : (new Array()));
	}

/* == Array Access == */

	@:arrayAccess
	public inline function get(i : Int):Null<Byte> {
		return (this[i]);
	}

	@:arrayAccess
	public inline function set(i:Int, nb:Byte):Null<Byte> {
		this[i] = nb;
		return this[i];
	}

/* == Instance Fields == */

	/**
	  * internal reference to [this] as a ByteArray
	  */
	private var self(get, never):ByteArray;
	private inline function get_self():ByteArray {
		return (cast this);
	}

	/**
	  * whether [this] ByteArray has any bytes in it
	  */
	public var empty(get, never):Bool;
	private inline function get_empty():Bool {
		return (this.length == 0);
	}

/* == Instance Methods == */

	/**
	  * For every Byte in [this] ByteArray,
	  * invokes [func] with the index of the current Byte as it's first argument,
	  * and the current Byte as it's second
	  * @param "func" [Int -> Byte -> Void] - Function to invoke for every Byte
	  * @param ?"start" [Int] - the position at which to start the iteration
	  * @param ?"end" [Int] - the position at which to end the iteration
	  */
	public function each(func:Int->Byte->Void, ?start:Int, ?end:Int):Void {
		//- starting position
		var index:Int = ((start != null) ? start : 0);
		//- stopping point
		var goal:Int = ((end != null) ? end : this.length);

		//- if start is negative
		if (index < 0) {
			//- this is valid if [end] was not provided
			if (end == null) {
				var _i:Int = index;
				index = (this.length + _i);
			}
			else {
				throw 'Invalid start index $index!';
			}
		}
		
		var cb:Byte;
		while (index < goal) {
			cb = get( index );
			func(index, cb);

			index++;
		}
	}

	/**
	  * Retrieve a subset of the contents of [this] ByteArray
	  */
	public function slice(start:Int, ?end:Int):ByteArray {
		return (this.slice(start, end));
	}

	/**
	  * Write a hunk of data to [this] ByteArray in the form of a String
	  */
	public function writeString(s : String):Void {
		for (c in s.split('')) {
			self.push( c );
		}
	}

/* == Operators == */

/* == Type Casting == */

	/* To Array<Byte> */
	@:to
	public inline function toArray():Array<Byte> {
		return this;
	}

	/* To Array<Int> */
	@:to
	public inline function toIntArray():Array<Int> {
		return this.map(function(b:Byte) return b.asint);
	}

	/* To String */
	@:to
	public inline function toString():String {
		return (this.map(function(b) return b.aschar).join(''));
	}

	/* To haxe.io.Bytes */
	@:to
	public inline function toBytes():Bytes {
		var buf = Bytes.alloc(this.length);
		
		each(function(i:Int, b:Byte) {
			buf.set(i, b.asint);
		});

		return buf;
	}

	/* To NodeJS Buffer */
	@:to
	public inline function toNodeBuffer():Dynamic {
		#if js
		var len:Int = this.length;
		var cl:Class<Dynamic> = untyped __js__('Buffer');
		var buf:Dynamic = Type.createInstance(cl, [self.toArray()]);
		
		return buf;
		#else
		throw 'Cannot create NODE Buffer outside of Node!';
		#end
	}

	/* From Array<Int> */
	@:from
	public static inline function fromIntArray(ia : Array<Int>):ByteArray {
		return new ByteArray(ia.map(function(n:Int) return new Byte(n)));
	}

	/* From Bytes */
	@:from
	public static inline function fromBytes(buf : Bytes):ByteArray {
		var ba:ByteArray = new ByteArray();
		
		if (buf.length > 0) {
			for (i in 0...buf.length) {
				var n:Int = buf.get(i);

				ba.push( n );
			}
		}

		return ba;
	}

	/* From NodeJS Buffer */
	public static inline function fromNodeBuffer(nb : Dynamic):ByteArray {
		var len:Int = cast nb.length;
		var bitlist:Array<Int> = new Array();
		for (i in 0...len) {
			bitlist.push(cast nb[i]);
		}

		return (cast bitlist);
	}

	/* From String */
	@:from
	public static inline function fromString(s : String):ByteArray {
		var ba:ByteArray = new ByteArray();
		ba.writeString( s );
		return ba;
	}

/* == Class Methods == */

}
