package tannus.io;

import tannus.io.BinaryData;
import tannus.io.impl.BinaryIterator;

import tannus.io.Byte;
import tannus.sys.Mime;
import tannus.math.TMath;
import haxe.Int64;

using Lambda;
using StringTools;
using tannus.ds.StringUtils;
using tannus.ds.ArrayTools;

class Binary {
	/* Constructor Function */
	public function new(size:Int, _b:BinaryData):Void {
		_length = size;
		b = _b;
		position = 0;
	}

	/* === Instance Methods === */

	/* get the byte at the given index */
	public function get(index : Int):Byte {
		return 0;
	}

	/* set the byte at the given index */
	public function set(index:Int, value:Byte):Byte {
		return 0;
	}

	/* read a 32bit integer from the given index */
	public function getInt32(i : Int):Int {
		return (get(i) | (get(i + 1) << 8) | (get(i + 2) << 16) | (get(i + 3) << 24));
	}

	/* store a 32bit integer to the given position */
	public function setInt32(i:Int, v:Int):Void {
		set(i, v);
		set(i+1, v >> 8);
		set(i+2, v >> 16);
		set(i+3, v >> 24);
	}

	/* read a 64bit integer */
	public inline function getInt64(i : Int):Int64 {
		return Int64.make(getInt32(i + 4), getInt32(i));
	}

	/* write a 64bit integer */
	public function setInt64(i:Int, v:Int64):Void {
		setInt32(i, v.low);
		setInt32(i+4, v.high);
	}

	/* read a Double */
	public inline function getDouble(i : Int):Float {
		return TMath.i64ToDouble(getInt32(i), getInt32(i + 4));
	}

	/* write a Double */
	public function setDouble(i:Int, v:Float):Void {
		var _i = TMath.doubleToI64( v );
		setInt32(i, _i.low);
		setInt32(i+4, _i.high);
	}

	/* read a Float */
	public inline function getFloat(i : Int):Float {
		return TMath.i32ToFloat(getInt32( i ));
	}

	/* write a Float */
	public inline function setFloat(i:Int, v:Float):Void {
		setInt32(i, TMath.floatToI32( v ));
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

	/* read a 32bit integer */
	public function readInt32():Int {
		var v = getInt32( position );
		position += 4;
		return v;
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
	public function shiftLeft(digits : Int):Void {
		var rpad:Binary = _alloc( digits );
		rpad.fill( 0 );
		var backward:ByteArray = slice( digits ).concat( rpad );
		grow( digits );
		//b = backward.b;
		setData( backward.b );
	}

	/* get a subset of [this] data */
	public function sub(index:Int, size:Int):Binary {
		throw 'Not implemented';
	}

	/* get a slice of [this] data */
	public function slice(min:Int, ?max:Int):ByteArray {
		return sub(min, ((max != null ? max : length) - min));
	}

	/* copy another Binary onto [this] one */
	public function blit(index:Int, src:Binary, srcIndex:Int, size:Int):Void {
		throw 'Not implemented';
	}

	/* resize [this] Binary data */
	public function resize(size : Int):Void {
		_length = size;
	}

	/* reverse [this] data in-place */
	public function reverse():Void {
		for (i in 0...length) {
			var ri:Int = (length - (i + 1));
			set(ri, get( ri ));
		}
	}

	/* grow [this] Binary by [amount] */
	private inline function grow(amount : Int):ByteArray {
		resize(length + amount);
		return this;
	}

	/* get the concatenation of [this] data and [other] */
	public function concat(other : ByteArray):ByteArray {
		throw 'Not implemented';
	}

	/* create and return a copy of [this] */
	public function copy():Binary {
		return this;
	}

	/* iterate over all Bytes in [this] */
	public function iterator():BinaryIterator {
		return new BinaryIterator( this );
	}

	/* get a subset of [this] data as a String */
	public function getString(index:Int, len:Int):String {
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
		return haxe.io.Bytes.ofData(untyped b);
	}

	/* convert [this] to a hexidecimal String */
	public function toHex():String {
		var sb = new StringBuf();
		var chars = ('0123456789ABCDEF'.split('').map(function(s) {
			return s.charCodeAt(0);
		}));
		for (i in 0...length) {
			var c = get( i );
			sb.addChar(chars[c >> 4]);
			sb.addChar(chars[c & 15]);
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
}