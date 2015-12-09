package tannus.io;

import tannus.io.Byte;

import haxe.io.Bytes;

@:forward
abstract ByteArray (Binary) from Binary to Binary {
	/* Constructor Function */
	private inline function new(bin : Binary):Void {
		this = bin;
	}

/* === Instance Methods === */

	@:arrayAccess
	public inline function get(i:Int):Byte return this.get(i);
	@:arrayAccess
<<<<<<< HEAD
	public inline function set(i:Int, v:Byte):Byte return this.set(i, v);
=======
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
	  * Convert [this] to a ByteStack
	  */
	public inline function stack():ByteStack {
		return new ByteStack(self);
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
>>>>>>> b5c059df8d1f39d87ad27136cf47e923c02cbdfe

	@:to
	public inline function toString():String return this.toString();

	@:to
	public inline function toBytes():haxe.io.Bytes return this.toBytes();

	@:to
	public inline function toBase():BinaryData return this.getData();

	@:to
	public inline function toArray():Array<Byte> return this.toArray();

	@:op(A += B)
	public inline function expand(other : ByteArray):ByteArray {
		return this.append( other );
	}

	@:op(A + B)
	public inline function concat(other : ByteArray):ByteArray {
		return this.concat( other );
	}

	@:op(A == B)
	public inline function equals(o : ByteArray):Bool {
		return this.equals(o);
	}

/* === Static Methods === */

	/* build a new Binary of the given size */
	public static inline function alloc(size : Int):ByteArray {
		return new ByteArray(cast BinaryImpl.alloc( size ));
	}

	/* build a Binary from some BinaryData */
	@:from
	public static inline function ofData(d : BinaryData):ByteArray {
		return new ByteArray(cast BinaryImpl.ofData( d ));
	}

	/* build a Binary from a String */
	@:from
	public static inline function ofString(s : String):ByteArray {
		return new ByteArray(cast BinaryImpl.ofString( s ));
	}

	/* build a Binary from haxe.io.Bytes */
	@:from
	public static inline function fromBytes(b : Bytes):ByteArray {
		return new ByteArray(cast BinaryImpl.fromBytes( b ));
	}

	/* build a Binary from a base-64 encoded String */
	public static inline function fromBase64(s : String):ByteArray {
		return new ByteArray(cast BinaryImpl.fromBase64( s ));
	}
}

#if python
	typedef BinaryImpl = tannus.io.impl.PythonBinary;
#elseif js
	typedef BinaryImpl = tannus.io.impl.JavaScriptBinary;
#else
	typedef BinaryImpl = tannus.io.impl.GenericBinary;
#end
