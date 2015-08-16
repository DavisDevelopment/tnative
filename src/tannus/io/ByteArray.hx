package tannus.io;

/* "haxe" imports */
import haxe.io.Bytes;
import haxe.io.BytesData;
import haxe.crypto.Base64;
import haxe.io.FPHelper in Fp;

/* "gen" imports */
import tannus.io.Byte;
import tannus.ds.Maybe;
import tannus.math.Nums;

/* == Platform-Specific Imports == */

#if python
/* "python" Imports */
//import python.lib.Bytes;
//import python.lib.Tuple;
#end

#if node
import tannus.node.Buffer;
#end

using Lambda;

/**
  * Abstract Class representing an Array of Bytes as an Entity unto itself, such as the contents of a File
  */
@:forward(length, push, pop, shift, unshift, filter, concat, copy)
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

	/**
	  * The 'first' Byte of [this] ByteArray
	  */
	public var first(get, set):Byte;
	private inline function get_first() return (this[0]);
	private inline function set_first(nf : Byte) return (this[0] = nf);

	/**
	  * The last Byte of [this] ByteArray
	  */
	public var last(get, set):Byte;
	private inline function get_last() return (this[this.length - 1]);
	private inline function set_last(nl : Byte) return (this[this.length-1] = nl);

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
		return (self.indexOf(sub) != -1);
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
	  * Get a String out of [this] ByteArray
	  */
	public function getString(?len : Int):String {
		return (slice(0, (len!=null?len:this.length)).toString());
	}

	/**
	  * Write a Float to [this] ByteArray
	  */
	public inline function writeFloat(f : Float):Void {
		var b:Bytes = self.toBytes();
		b.setFloat(this.length, f);
		this = fromBytes( b ).toArray();
	}

	/**
	  * Read a Float from [this] ByteArray
	  */
	public inline function readFloat(?i : Int):Float {
		if (i == null)
			i = this.length;
		var b:Bytes = self.toBytes();
		var res:Float = b.getFloat(this.length);
		this = fromBytes(b).toArray();
		return res;
	}

	/**
	  * Write a hunk of data to [this] ByteArray in the form of a ByteArray
	  */
	@:op(A += B)
	public inline function write(ba : ByteArray):Void {
		this = (this.concat(ba));
	}

	/**
	  * Write a sigle Byte onto [this] ByteArray
	  */
	@:op(A += B)
	public inline function writeByte(b : Byte):Void {
		this.push( b );
	}

	public function append(data : ByteArray):Void {
		for (b in data)
			this.push( b );
	}

	/**
	  * Convert [this] ByteArray to a DataURI
	  */
	public inline function toDataURI(?mime:String='text/plain'):String {
		var encoded:String = haxe.crypto.Base64.encode( self);
		return 'data:$mime;base64,$encoded';
	}

	/**
	  * Rip a Chunk of [this] ByteArray from either the beginning or the end
	  */
	public function chunk(len:Int, ?end:Bool=false):Array<Byte> {
		var chnk:Array<Byte> = new Array();
		var rip:Getter<Null<Byte>> = new Getter((end?this.pop:this.shift).bind());

		for (i in 0...len) {
			var b:Null<Byte> = rip.get();

			if (b != null) {
				chnk.push( b );
			}
			else {
				throw 'IncompleteChunkError: Byte-Retrieval failed on byte $i/$len!';
			}
		}

		return chnk;
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

	#if node
		/* To NodeJS Buffer */
		@:to
		public inline function toNodeBuffer():Buffer {
			return new Buffer(toIntArray());
		}
	#end

	#if (js && !node)
		/**
		  * Cast [this] ByteArray to a Uint8Array
		  */
		@:to
		public function toUint8Array():js.html.Uint8Array {
			return new js.html.Uint8Array(untyped toArray());
		}

		#if !chromeapp
			/**
			  * Cast [this] ByteArray to an ArrayBuffer
			  */
			@:to
			public function toArrayBuffer():js.html.ArrayBuffer {
				return cast toUint8Array();
			}
		#end
	#end

	#if python
		/* To Python bytearray */
		@:to
		public inline function toPythonByteArray():python.Bytearray {
			return new python.Bytearray(python.Lib.toPythonIterable(toIntArray()));
		}

		/* To Python Bytes */
		@:to
		public function toPythonBytes():python.Bytes {
			//- Create new python.Bytes instance
			var bits = new python.Bytes( this.length );

			//- Write each Byte of [this] ByteArray to [bits]
			for (i in 0...this.length) {
				var byte:Byte = get( i );
				bits.set(i, byte.asint);
			}

			return bits;
		}

		/* From Python Bytes */
		@:from
		public static function fromPythonBytes(b : python.Bytearray):ByteArray {
			var ba:ByteArray = new ByteArray();

			for (i in 0...b.length) {
				ba[i] = b.get(i);
			}

			return ba;
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

	/* From Array<Float> */
	@:from
	public static inline function fromFloatArray(ia : Array<Float>):ByteArray {
		return new ByteArray(ia.map(function(n:Float) return new Byte(Math.round(n))));
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

	#if (js && !node)
		/* From ArrayBuffer */
		@:from
		public static inline function fromArrayBuffer(abuf : js.html.ArrayBuffer):ByteArray {
			var ui = new js.html.Uint8Array( abuf );
			return fromIntArray([for (i in ui) i]);
		}
	#end

	#if node
		/* From NodeJS Buffer */
		@:from
		public static inline function fromNodeBuffer(nb : Buffer):ByteArray {
			var len:Int = nb.length;
			var bitlist:Array<Int> = new Array();
			for (i in 0...len) {
				bitlist.push( nb[i] );
			}

			return (cast bitlist);
		}
	#end

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
