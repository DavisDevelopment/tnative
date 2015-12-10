package tannus.io.impl;

import tannus.io.Byte;
import js.html.ArrayBuffer;
import js.html.DataView;
import js.html.Uint8Array;

using Lambda;
using tannus.ds.ArrayTools;

@:expose('Binary')
class JavaScriptBinary extends Binary {
	/* Constructor Function */
	public function new(size:Int, data:ArrayBuffer, ?arr:Uint8Array):Void {
		super(size, data);

		array = (arr != null ? arr : new Uint8Array( data ));
	}

	/* === Instance Methods === */

	/* get a byte */
	override public function get(i:Int):Byte {
		super.get( i );
		return array[i];
	}

	/* set a byte */
	override public function set(i:Int, v:Byte):Byte {
		super.set(i, v);
		return (array[i] = v);
	}

	/* get a subset of [this] data */
	override public function sub(index:Int, size:Int):Binary {
		return new JavaScriptBinary(size, b.slice(index, (index + size)));
	}

	/* get a 'slice' of [this] data */
	override public function slice(start:Int, ?end:Int):Binary {
		if (end == null) {
			end = length;
		}
		return new JavaScriptBinary((end - start), b.slice(start, end));
	}

	/* copy another chunk of data onto [this] one */
	override public function blit(index:Int, src:Binary, srcIndex:Int, size:Int):Void {
		for (i in 0...size) {
			set((index + i), src.get(srcIndex + i));
		}
	}

	/* read a String from [this] data */
	override public function getString(index:Int, size:Int):String {
		var result:String = '';
		for (i in 0...size) {
			result += get(index + i);
		}
		return result;
	}

	/* resize [this] data */
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

	/* concatenate [this] data with [other] */
	override public function concat(other : ByteArray):ByteArray {
		var lensum:Int = (length + other.length);
		var sum = new JavaScriptBinary(lensum, new ArrayBuffer(lensum));
		sum.blit(0, this, 0, length);
		sum.blit(length, other, 0, other.length);
		return sum;
	}

	/* do other stuff */
	override private function setData(d : BinaryData):Void {
		b = d;
		array = new Uint8Array(b);
		_length = array.length;
	}

	/* convert [this] to a node.js Buffer */
	public function toBuffer():tannus.node.Buffer {
		return (new tannus.node.Buffer(untyped array));
	}

	/* === Instance Fields === */

	private var array : Null<Uint8Array>;

	/* === Static Methods === */

	/* create new empty data of given size */
	public static function alloc(size : Int):JavaScriptBinary {
		var list:Uint8Array = new Uint8Array( size );
		var data = list.buffer;
		return new JavaScriptBinary(size, data, list);
	}

	/* create new Binary from existing data */
	public static function ofData(d : BinaryData):JavaScriptBinary {
		var copy = cast(d, ArrayBuffer).slice(0);
		return new JavaScriptBinary(d.byteLength, copy);
	}

	/* create a new Binary from a String */
	public static function ofString(s : String):JavaScriptBinary {
		if (s == '') {
			throw 'Error: Dealing with empty Strings is too much bullshit';
		}

		var a:Array<Int> = new Array();
		// utf16-decode and utf8-encode
		var i:Int = 0;
		while(i < s.length) {
			var c : Int = StringTools.fastCodeAt(s,i++);
			// surrogate pair
			if( 0xD800 <= c && c <= 0xDBFF )
				c = (c - 0xD7C0 << 10) | (StringTools.fastCodeAt(s,i++) & 0x3FF);
			if( c <= 0x7F )
				a.push(c);
			else if( c <= 0x7FF ) {
				a.push( 0xC0 | (c >> 6) );
				a.push( 0x80 | (c & 63) );
			} 
			else if( c <= 0xFFFF ) {
				a.push( 0xE0 | (c >> 12) );
				a.push( 0x80 | ((c >> 6) & 63) );
				a.push( 0x80 | (c & 63) );
			} 
			else {
				a.push( 0xF0 | (c >> 18) );
				a.push( 0x80 | ((c >> 12) & 63) );
				a.push( 0x80 | ((c >> 6) & 63) );
				a.push( 0x80 | (c & 63) );
			}
		}
		var tarr:Uint8Array = new Uint8Array( a );
		return new JavaScriptBinary(a.length, tarr.buffer);
	}

	/* create a new Binary from a Buffer */
	public static function fromBuffer(b : tannus.node.Buffer):JavaScriptBinary {
		var jsb:JavaScriptBinary = alloc(b.length);
		for (i in 0...b.length)
			jsb.set(i, b[i]);
		return jsb;
	}

	/* create a new Binary from Bytes */
	public static function fromBytes(b : haxe.io.Bytes):JavaScriptBinary {
		return ofData(untyped b.getData());
	}

	/* convert a Uint8Array to a normal Array */
	private static inline function list(uia : DataView):Array<Byte> {
		return (untyped __js__('Array.prototype.slice.call'))(uia, 0);
	}
	
	/* create a Binary from a base-64 encoded String */
	public static function fromBase64(s : String):JavaScriptBinary {
		return fromBytes(haxe.crypto.Base64.decode(s));
	}
}
