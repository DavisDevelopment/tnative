package tannus.io;

import tannus.io.BinaryData;
import tannus.io.impl.BinaryIterator;
import tannus.io.impl.BinaryError;
import tannus.internal.TypeTools.typename;

import tannus.io.Byte;
import tannus.sys.Mime;
import tannus.math.TMath;
import tannus.ds.Obj;

import tannus.math.TMath.*;

import haxe.Int64;
import haxe.io.*;

//import Math.*;

using Type;
using Lambda;
using StringTools;
using tannus.ds.StringUtils;
using tannus.ds.ArrayTools;
using tannus.math.TMath;

#if js
class Binary implements tannus.html.Blobable {
#else
class Binary {
#end
	/* Constructor Function */
	public function new(size:Int, _b:BinaryData):Void {
		_length = size;
		b = _b;
		position = 0;
	}

	/* === Instance Methods === */

	/* get the byte at the given index */
	public function get(index : Int):Byte {
		if (index >= length || index < 0) {
			outOfBounds();
		}
		return 0;
	}

	/* set the byte at the given index */
	public function set(index:Int, value:Byte):Byte {
		if (index >= length || index < 0) {
			outOfBounds();
		}
		return 0;
	}

	/* read a 32bit integer from the given index */
	//public function getInt32(i : Int):Int {
		//var a:Int = get( i );
		//var b:Int = get(i + 1);
		//var c:Int = get(i + 2);
		//var d:Int = get(i + 3);
		//return (bigEndian ? (d | (c << 8) | (b << 16) | (a << 24)) : (a | (b << 8) | (c << 16) | (d << 24)));
	//}

     //read unsigned 32bit integer from given index 
	//public function getUint32(i: Int):Int {
		//return signedToUnsigned(getInt32( i ));
	//}

	/* read a 64bit integer */
	public inline function getInt64(i : Int):Int64 {
		return Int64.make(getInt32(i + 4), getInt32( i ));
	}

	/* write a 64bit integer */
	public function setInt64(i:Int, v:Int64):Void {
		setInt32(i, v.low);
		setInt32(i+4, v.high);
	}

	/* read a Double */
	/*
	public inline function getDouble(i : Int):Float {
		return TMath.i64ToDouble(getInt32( i ), getInt32(i + 4));
	}
	*/

	/* write a Double */
	/*
	public function setDouble(i:Int, v:Float):Void {
		var _i = TMath.doubleToI64( v );
		setInt32(i, _i.low);
		setInt32(i+4, _i.high);
	}
	*/

	/* read a Float */
	public inline function getFloat(i : Int):Float {
		return TMath.i32ToFloat(getInt32( i ));
	}

	/* write a Float */
	public inline function setFloat(i:Int, v:Float):Void {
		setInt32(i, TMath.floatToI32( v ));
	}

    public inline function getUInt8(i: Int):Int return get( i );
	public function getInt8(i: Int):Int {
	    var n:Int = getUInt8( i );
	    if (n >= 128) {
	        return (n - 256);
	    }
	    return n;
	}

	public function getUInt16(i: Int):Int {
	    var a:Int = getUInt8(i + 0);
	    var b:Int = getUInt8(i + 1);
		//return bigEndian ? b | (a << 8) : a | (b << 8);
	    return 
	        if ( bigEndian )
	            b | (a << 8)
            else
                a | (b << 8);
	}

	public function getInt16(i: Int):Int {
	    var a:Int = getUInt8(i + 0);
	    var b:Int = getUInt8(i + 1);
	    var n:Int = bigEndian ? b | (a << 8) : a | (b << 8);
	    if (n & 0x8000 != 0)
	        return n - 0x10000;
	    return n;
	}

	public function getInt24(i: Int):Int {
	    var a = getUInt8(i + 0),
	    b = getUInt8(i + 1),
	    c = getUInt8(i + 2),
	    n = bigEndian 
	        ? c | (b << 8) | (a << 16) 
	        : a | (b << 8) | (c << 16);
	    if (n & 0x80000 != 0)
	        return n - 0x100000;
	    return n;
	}

	public function getUInt24(i: Int):Int {
	    var a = getUInt8(i + 0),
	    b = getUInt8(i + 1),
	    c = getUInt8(i + 2);
	    return bigEndian 
	        ? c | (b << 8) | (a << 16) 
	        : a | (b << 8) | (c << 16);
	}

	public function getUInt32(i: Int):Int {
	    var a = getUInt8(i + 0),
	    b = getUInt8(i + 1),
	    c = getUInt8(i + 2),
	    d = getUInt8(i + 3);
	    return bigEndian
	        ? d | (c << 8) | (b << 16) | (a << 24)
	        : a | (b << 8) | (c << 16) | (d << 24);
	}

	public function getInt32(i: Int):Int {
	    var n:Int = getUInt32( i );
	    if (n & 0x80000000 != 0)
	        return (n | 0x80000000);
	    return n;
	}

	public inline function setUInt8(i:Int, v:Int):Int return set(i, v);
	public inline function setInt8(i:Int, v:Int):Int {
	    return setUInt8(i, v & 0xFF);
	}

	public function setUInt16(i:Int, v:Int):Int {
	    if ( bigEndian ) {
            setUInt8(i + 0, v >> 8);
            setUInt8(i + 1, v & 0xFF);
        }
        else {
            setUInt8(i + 0, v & 0xFF);
            setUInt8(i + 1, v >> 8);
        }
        return v;
	}

	public inline function setInt16(i:Int, v:Int):Int {
	    return setUInt16(i, v & 0xFFFF);
	}

	public function setUInt24(i:Int, v:Int):Int {
	    if ( bigEndian ) {
	        setUInt8(i + 0, v >> 16);
	        setUInt8(i + 1, (v >> 8) & 0xFF);
	        setUInt8(i + 2, v & 0xFF);
	    }
        else {
            setUInt8(i + 0, v & 0xFF);
            setUInt8(i + 1, (v >> 8) & 0xFF);
            setUInt8(i + 2, v >> 16);
        }
        return v;
	}

	public inline function setInt24(i:Int, v:Int):Int {
	    return setUInt24(i, v & 0xFFFFFF);
	}

	public function setUInt32(i:Int, v:Int):Int {
	    if ( bigEndian ) {
	        setUInt8((i + 0), (v >> 24));
	        setUInt8((i + 1), (v >> 16));
	        setUInt8((i + 2), (v >> 8 ));
	        setUInt8((i + 3), (v/*  */));
	    }
        else {
            setUInt8((i + 0), (/* */ v));
            setUInt8((i + 1), (v >>  8));
            setUInt8((i + 2), (v >> 16));
            setUInt8((i + 3), (v >> 24));
        }
		return v;
	}

	/* store a 32bit integer to the given position */
	public function setInt32(i:Int, v:Int):Void {
		set(i, v);
		set(i+1, v >> 8);
		set(i+2, v >> 16);
		set(i+3, v >> 24);
	}

	/* fill [this] data with the given Byte */
	public function fill(c:Byte, ?index:Int, ?size:Int):Void {
		if (index == null)
			index = 0;
		if (size == null)
			size = length;
		for (i in index...size) {
			set(i, c);
		}
	}

	/* read the next byte */
	public inline function readByte():Byte {
		return get(position++);
	}
	public inline function readUInt8():Int return get(position++);

	public function readInt8():Int {
	    var n:Int = readByte();
	    if (n >= 128) {
	        return (n - 256);
	    }
	    return n;
	}

	public function readInt16():Int {
	    var a:Int = readByte(), b:Int = readByte();
	    var n = bigEndian ? b | (a << 8) : a | (b << 8);
	    if (n & 0x8000 != 0) {
	        return n - 0x10000;
	    }
	    return n;
	}

    // read an unsigned 24-bit integer
	public function readUInt24():Int {
	    var a=readUInt8(),b=readUInt8(),c=readUInt8();
	    return bigEndian ? (c | (b << 8) | (a << 16)) : (a | (b << 16) | (c << 8));
	}

    // read a signed 24-bit integer
	public function readInt24():Int {
	    var a=readUInt8(),b=readUInt8(),c=readUInt8();
	    var n = bigEndian ? (c | (b << 8) | (a << 16)) : (a | (b << 16) | (c << 8));
	    if (n & 0x800000 != 0) {
	        return n - 0x1000000;
	    }
	    return n;
	}

	public function readUInt16():Int {
	    var a:Int = readByte(), b:Int = readByte();
	    return bigEndian ? b | (a << 8) : a | (b << 8);
	}

	/* read a 32bit integer */
	public function readInt32():Int {
        var v = getInt32( position );
        position += 4;
        return v;
        /*
		var a:Int = readByte();
		var b:Int = readByte();
		var c:Int = readByte();
		var d:Int = readByte();
		return (bigEndian ? (d | (c << 8) | (b << 16) | (a << 24)) : (a | (b << 8) | (c << 16) | (d << 24)));
		*/
	}

    // read unsigned 32bit integer
	public inline function readUInt32():Int {
	    return signedToUnsigned(readInt32());
	}

    private static var MAX64:Int = {Std.int(Math.pow(2, 32));};
	public function readUInt64():Int {
	    return ((readInt32() * MAX64) + readInt32());
	}

	public function readInt64():Int {
	    var a = readInt32(), b = readInt32();
	    var res:Int = a;
	    res = (res << 32);
	    return (res | b);
	}

	public function readUInt8Array(len : Int):UInt8Array {
	    var arr = new UInt8Array( len );
	    for (i in 0...len) {
	        arr.set(i, readByte());
	    }
	    return arr;
	}

	/* write a 32bit integer */
	public function writeInt32(i : Int):Void {
		setInt32(position, i);
		position += 4;
	}

	/* read a Float */
	public inline function readFloat():Float {
		return TMath.i32ToFloat(readInt32());
	}

	/* write a Float */
	public inline function writeFloat(v : Float):Void {
		writeInt32(TMath.floatToI32( v ));
	}

	/* write the next byte */
	public inline function writeByte(c : Byte):Void {
		set(position++, c);
	}

	private inline function signedToUnsigned(n : Int):Int return (n >>> 0);

	/* 

	/* read the next [len] bytes */
	public function read(len : Int):Binary {
		var res:Binary = sub(position, len);
		position += len;
		return res;
	}

	/* read a String from [this] data */
	public function readString(len : Int):String {
		var res:String = getString(position, len);
		position += len;
		return res;
	}

	/* write the given ByteArray onto [this] one */
	public function write(other:ByteArray, ?len:Int):Void {
		if (len == null)
			len = other.length;
		blit(position, other, 0, len);
		position += len;
	}

	/* write the given String onto [this] data */
	public function writeString(s : String):Void {
		write(_ofString( s ));
	}

	/* add a Byte to the end of [this] data */
	public function push(c : Byte):Int {
		seek( length );
		grow( 1 );
		setData( b );
		writeByte( c );
		return position;
	}

	/* write a 32-bit integer to the end of [this] data */
	public function pushInt32(i : Int):Int {
		seek( length );
		grow( 4 );
		setData( b );
		writeInt32( i );
		return position;
	}

	/* write a Float to the end of [this] data */
	public function pushFloat(n : Float):Int {
		return pushInt32(TMath.floatToI32( n ));
	}

	public inline function pushString(s : String):Void {
		appendString( s );
	}

	/* add a Byte to the beginning of [this] data */
	public function unshift(c : Byte):Int {
		shiftRight( 1 );
		setData( b );
		set(0, c);
		return 0;
	}

	/* remove the last Byte from [this] data, and return it */
	public function pop():Byte {
		var v:Byte = last;
		seek( 0 );
		resize(length - 1);
		setData( b );
		return v;
	}

	/* remove the first Byte from [this] data, and return it */
	public function shift():Byte {
		var v:Byte = first;
		setData( copy().slice(1).b );
		return v;
	}

	/* add [footer] to the end of [this] data, will grow [this] data as needed */
	public function append(footer:ByteArray, ?len:Int):ByteArray {
		if (len == null) {
			len = footer.length;
		}
		seek( length );
		grow( len );
		write( footer );
		return this;
	}

	/* append a String to [this] */
	public function appendString(foot:String, ?len:Int):ByteArray {
		return append(_ofString(foot), len);
	}

	/* append an Object to [this] */
	public function appendStruct(od : Dynamic):Int {
		var o:Obj = Obj.fromDynamic( od );
		if (o.exists( '_append_ba' )) {
			var a:Binary->Void = o.method( '_append_ba' );
			var _i:Int = position;
			a( this );
			var len:Int = (position - _i);
			return len;
		}
		else {
			throw 'Error: $o Cannot be written to a ByteArray';
			return -1;
		}
	}

	/**
	  * read data from [this] ByteArray, as an instance of the given Class
	  */
	public function readStruct(type : Class<Dynamic>):Dynamic {
		var ocl:Obj = Obj.fromDynamic( type );
		if (ocl.exists( '_from_ba' )) {
			var _from:ByteArray->Dynamic = ocl.method( '_from_ba' );
			return _from( this );
		}
		else {
			throw 'Error: ${typename( type )} has no "_from_ba" method';
		}
	}

	/* add [header] to the beginning of [this] data */
	public inline function prepend(header:ByteArray, ?len:Int):ByteArray {
		if (len == null) {
			len = header.length;
		}
		shiftRight( header.length );
		seek( 0 );
		write( header );
		return this;
	}
	
	/* prepend a String to [this] */
	public inline function prependString(head:String, ?len:Int):ByteArray {
		return prepend(_ofString(head), len);
	}

	/* shift all bytes in [this] data [digits] to the right */
	public function shiftRight(digits : Int):Void {
		var lpad:Binary = _alloc( digits );
		lpad.fill( 0 );
		lpad = lpad.concat( this );
		grow( digits );
		setData( lpad.b );
	}

	/* shift all bytes in [this] data [digits] to the left */
	public function shiftLeft(digits:Int, pad:Bool=true):Void {
	    if ( pad ) {
            var rpad:Binary = _alloc( digits );
            rpad.fill( 0 );
            var backward:ByteArray = slice( digits ).concat( rpad );
            grow( digits );
            setData( backward.b );
        }
        else {
            var trunc = slice( digits );
            resize( trunc.length );
            setData( trunc.b );
        }
	}

	/* truncate [this] */
	public function truncate(len: Int):Void {
	    if (!(!len.isNaN() && len.isFinite()) || len > length || len < 0) {
	        throw 'BinaryError: Invalid truncation length ($len)';
	    }
        else if (len < length) {
            setData(sub(0, len).b);
            resize( len );
        }
	}

	/* get a subset of [this] data */
	public function sub(index:Int, size:Int):Binary {
		throw 'Not implemented';
	}

	/* get a slice of [this] data */
	public function slice(min:Int, ?max:Int):ByteArray {
		return sub(min, ((max != null ? max : length) - min));
	}

    /**
      * performs splice operation on [this]
      */
	public function splice(pos:Int, len:Int):ByteArray {
	    if (len < 0 || pos > length) {
	        return ByteArray.alloc( 0 );
	    }
        else {
            if (pos < 0)
                pos = (length + pos);
            if (pos < 0)
                pos = 0;
            len = TMath.min(len, (length - pos));
            var max = (pos + len);
            var result = slice(pos, (max + 1));
            if (pos == 0) {
                var remainder = slice(max + 1);
                rebase( remainder );
            }
            else {
                var pre:ByteArray, post:ByteArray;
                pre = slice(0, (pos - 1));
                post = slice(max + 1);
                blit(0, pre, 0, pre.length);
                blit(pre.length, post, 0, post.length);
                truncate(pre.length + post.length);
            }
            return result;
        }
	}

	/* copy another Binary onto [this] one */
	public function blit(index:Int, src:Binary, srcIndex:Int, size:Int):Void {
		throw 'Not implemented';
	}

	/* resize [this] Binary data */
	public function resize(size : Int):Void {
		_length = size;
	}

    /* alter [this] such that it becomes identical to [x] */
	private function rebase(x: Binary):Void {
	    setData(x.getData());
	    resize( x.length );
	}

	/* reverse [this] data in-place */
	public function reverse():Void {
	    /**
	      [=INEFFICIENT=] 
	      should be overridden where possible
	     **/
	    var temp: Int;
		for (i in 0...floor(length / 2)) {
			temp = getUInt8( i );
			setUInt8(i, getUInt8(length - i - 1));
			setUInt8((length - i - 1), temp);
		}
	}

	/* grow [this] Binary by [amount] */
	private inline function grow(amount : Int):ByteArray {
		resize(length + amount);
		return this;
	}

	/* get the concatenation of [this] data and [other] */
	public function concat(other : ByteArray):ByteArray {
	    /*[TODO] this method needs to be implemented by child-classes */
		throw 'Not implemented';
	}

	/* create and return a copy of [this] */
	public function copy():Binary {
	    /*[TODO] this method needs to be implemented by child-classes */
		return this;
	}

	/* iterate over all Bytes in [this] */
	public function iterator():Iterator<Byte> {
		//return new BinaryIterator( this );
		return tannus.ds.IteratorTools.map((0...length), get);
	}

	/* get a subset of [this] data as a String */
	public function getString(index:Int, len:Int):String {
	    /*[TODO] this method needs to be implemented by child-classes */
		return '';
	}

	/* get a reference to the underlying data */
	public inline function getData():BinaryData {
		return b;
	}

	/* set the position */
	public inline function seek(i : Int):Int {
		return (position = i);
	}

	/* convert [this] data into a String */
	public function toString():String {
		return getString(0, length);
	}

	/* convert [this] to a haxe.io.Bytes object */
	public function toBytes():haxe.io.Bytes {
	    /*[TODO] this method needs to be implemented by child-classes */
		return haxe.io.Bytes.alloc( 0 );
	}

	/* convert [this] to a hexidecimal String */
	public function toHex():String {
		var sb: StringBuf = new StringBuf(),
		/* */c: Int;

		for (i in 0...length) {
			c = getUInt8( i );
			sb.addChar(hex_chars.charCodeAt(c >> 4));
			sb.addChar(hex_chars.charCodeAt(c & 15));
		}

		return sb.toString();
	}

	/* encode [this] data using Base64 */
	public function base64Encode():String {
		return haxe.crypto.Base64.encode(toBytes());
	}
	public function toBase64():String return base64Encode();

	/* convert [this] data into a data-uri */
	public function toDataUrl(type:Mime='text/plain'):String {
		var encoded:String = base64Encode();
		return 'data:$type;base64,$encoded';
	}

	/* the array of Bytes from which [this] is made */
	public function toArray():Array<Byte> {
		return [for (c in this) c];
	}

#if js
	public inline function toBlob(callback:js.html.Blob->Void, ?type:String):Void {
		callback(new js.html.Blob([untyped getData()], {type: type}));
	}
#end

    /* lexicographically compare [this] to [other] */
    public function compareTo(other: Binary):Int {
        var compLen = TMath.min(length, other.length);
        return _compare(this, other, 0, 0, compLen);
    }

    public function indexOf(sub: ByteArray):Int {
        var ilen = (length - sub.length);
        for (index in 0...ilen) {
            var c = _compare(this, sub, index, 0, sub.length);
            if (c == 0) {
                return index;
            }
        }
        return -1;
    }

	/* check if [this] and [other] are equivalent in content */
	public function equals(other : Binary):Bool {
		if (length != other.length)
			return false;
		else {
			for (i in 0...length)
				if (get(i) != other.get(i))
					return false;
			return true;
		}
	}

	/* reassign the underlying data for [this] data */
	private function setData(data : BinaryData):Void {
		b = data;
	}

	/* throw a BinaryError */
	private inline function err(e : BinaryError):Void {
		throw e;
	}
	private inline function outOfBounds():Void {
		err( OutOfBounds );
	}
	private inline function overflow():Void {
		err( Overflow );
	}

	/* do the stuff */
	@:protected
	private function _alloc(size : Int):ByteArray {
		var allocf:Int->ByteArray = untyped Reflect.getProperty(Type.getClass(this), 'alloc');
		return allocf( size );
	}

	@:protected
	private inline function _ofString(s : String):ByteArray {
		return ((untyped Reflect.getProperty(Type.getClass(this), 'ofString'))( s ));
	}

	@:protected
	private function _compare(a:Binary, b:Binary, posA:Int, posB:Int, len:Int):Int {
	    inline function ic(a:Int, b:Int):Int return (a == b) ? 0 : ((a > b) ? 1 : -1);
	    var c: Int;
	    for (index in 0...len) {
	        c = ic(a.get(posA + index).asint, b.get(posB + index).asint);
	        if (c != 0) {
	            return c;
	        }
	    }
	    return 0;
	}

	static var hex_chars:String = '0123456789ABCDEF';

	/* === Computed Instance Fields === */

	/* the size of [this] data */
	public var length(get, never):Int;
	private inline function get_length():Int return _length;

	/* whether [this] data is empty */
	public var empty(get, never):Bool;
	private inline function get_empty():Bool return (length <= 0);

	/* the first Byte */
	public var first(get, set):Byte;
	private inline function get_first():Byte return get(0);
	private inline function set_first(v : Byte):Byte return set(0, v);
	
	/* the last Byte */
	public var last(get, set):Byte;
	private inline function get_last():Byte return get(length - 1);
	private inline function set_last(v : Byte):Byte return set((length - 1), v);

	/* === Instance Fields === */

	private var _length : Int;
	private var b : BinaryData;
	public var position : Int;
	public var bigEndian: Bool = false;
}
