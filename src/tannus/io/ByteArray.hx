package tannus.io;

/* "haxe" imports */
import haxe.io.Bytes;
import haxe.io.BytesData;
import haxe.crypto.Base64;

/* "gen" imports */
import tannus.io.Byte;

import tannus.math.Nums;

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
@:forward(length, push, pop, shift, unshift, filter, concat)
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

	/**
	  * Forward the 'iterator' method
	  */
	public inline function iterator():Iterator<Byte> {
		return (this.iterator());
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
	  * Check to see if the numerical sequence described by [sub]
	  * is present anywhere in [this] ByteArray, and return the
	  * index at which said sequence starts
	  */
	public function indexOf(sub : ByteArray):Int {
		for (i in 0...(self.length - sub.length)) {
			var hunk:ByteArray = self.slice(i, (i + sub.length));
			trace( hunk );

			if (hunk == sub) {
				return i;
			}
		}

		return -1;
	}

	/**
	  * Check whether [this] contains [sub]
	  */
	public function contains(sub : ByteArray):Bool {
		return (indexOf(sub) != -1);
	}

	/**
	  * Write a hunk of data to [this] ByteArray in the form of a String
	  */
	public function writeString(s : String):Void {
		for (c in s.split('')) {
			self.push( c );
		}
	}

	/**
	  * Write a hunk of data to [this] ByteArray in the form of a ByteArray
	  */
	@:op(A += B)
	public inline function write(ba : ByteArray):Void {
		this = (this.concat(ba));
	}

	/**
	  * Convert [this] ByteArray to a DataURI
	  */
	public inline function toDataURI(?mime:String='text/plain'):String {
		var encoded:String = haxe.crypto.Base64.encode( self);
		return 'data:$mime;base64,$encoded';
	}

/* == Operators == */

	/* Equality Testing */
	@:op(A == B)
	public function equals_byteArray(other : ByteArray):Bool {
		if (self.length != other.length) {
			return false;
		} 
		else {
			var i:Int = 0;
			while (i < self.length) {
				if (self[i] != other[i]) {
					return false;
				}

				i++;
			}
			return true;
		}
	}

	/**
	  * The result of [this] ByteArray added to another
	  */
	@:op(A + B)
	public inline function plus(other : ByteArray):ByteArray {
		return (this.concat(other));
	}

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

	/* To Base64 String */
	public inline function toBase64():String {
		var b:Bytes = self;
		return Base64.encode( b );
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

	#if python
	/* To Python bytearray */
	@:to
	public inline function toPythonByteArray():python.lib.ByteArray {
		var ia:Array<Int> = toIntArray();
		var ba:Dynamic = python.Syntax.pythonCode('bytearray(ia)');

		return cast ba;
	}
	#end

	#if (flash || as3)
	/* To Flash ByteArray */
	@:to
	public inline function toFlashByteArray():flash.utils.ByteArray {
		var b = new flash.utils.ByteArray();

		for (n in this) {
			b.writeByte(n.asint);
		}

		return b;
	}

	/* From Flash ByteArray */
	@:from
	public static inline function fromFlashByteArray(b : flash.utils.ByteArray):ByteArray {
		var ba:ByteArray = new ByteArray();

		b.position = 0;
		for (i in 0...b.length) {
			b.position = i;
			ba.push(b.readByte());
		}

		return ba;
	}
	#end

	#if java
	
	/* To java.lang.byte[] */
	@:to
	public inline function toJavaByteArray():java.NativeArray<java.lang.Byte> {
		var _ba:Array<java.lang.Byte> = this.map(function(b : Byte) return b.toJavaByte());

		return untyped java.Lib.nativeArray(_ba, false);
	}

	#end

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

	/* From Base64 String */
	public static inline function fromBase64(s : String):ByteArray {
		var b:Bytes = Base64.decode(s);
		return b;
	}

/* == Class Methods == */

}
