package tannus.io.impl;

import tannus.io.Byte;
import tannus.math.TMath.*;

import python.Syntax;
import python.Bytearray;

class PythonBinary extends Binary {
	/* Constructor Function */
	public function new(size:Int, data:BinaryData):Void {
		super(size, data);
	}

	/* === Instance Methods === */

	/* get a value */
	override public function get(i : Int):Byte {
		super.get( i );
		return Syntax.arrayAccess(b, i);
	}

	/* set a value */
	override public function set(i:Int, v:Byte):Byte {
		super.set(i, v);
		Syntax.pythonCode('self.b[{0}] = {1}', i, v.asint);
		return v;
	}

	/* get a sub-data */
	override public function sub(index:Int, size:Int):Binary {
		return new PythonBinary(size, Syntax.arrayAccess(b, index, (index + size)));
	}

	/* blit some data */
	override public function blit(index:Int, src:Binary, srcIndex:Int, size:Int):Void {
		Syntax.pythonCode("self.b[{0}:{0}+{1}] = src.b[srcIndex:srcIndex+{1}]", index, size);
	}

	/* get the String content of [this] */
	override public function getString(i:Int, size:Int):String {
		return python.Syntax.pythonCode("self.b[{0}:{0}+{1}].decode('UTF-8','replace')", i, size);
	}

	/* resize [this] data */
	override public function resize(size : Int):Void {
		var _backup:BinaryData = Syntax.arrayAccess(b, 0, length);
		var lsize:Int = length;
		super.resize( size );
		b = new Bytearray( size );
		Syntax.pythonCode("self.b[0:{0}] = _backup[0:]", lsize);
	}

	/* concatenate [this] data with another */
	override public function concat(other : ByteArray):ByteArray {
		return ofData(Syntax.binop(b, '+', other.b));
	}

	/* copy [this] data */
	override public function copy():Binary {
		return ofData(Syntax.arrayAccess(b, 0, length));
	}

	/* === Static Methods === */

	/* create a new Binary of the given size */
	public static function alloc(size : Int):PythonBinary {
		return new PythonBinary(size, new Bytearray(size));
	}

	/* create a new Binary from some BinaryData */
	public static function ofData(d : BinaryData):PythonBinary {
		return new PythonBinary(d.length, Syntax.arrayAccess(d, 0, d.length));
	}

	/* create a new Binary from a String */
	public static function ofString(s : String):PythonBinary {
		return new PythonBinary(s.length, new Bytearray(s, 'UTF-8'));
	}
	
	/* create a new Binary from Bytes */
	public static function fromBytes(b : haxe.io.Bytes):PythonBinary {
		return ofData(untyped b.getData());
	}
	
	/* create a Binary from a base-64 encoded String */
	public static function fromBase64(s : String):PythonBinary {
		return fromBytes(haxe.crypto.Base64.decode(s));
	}
}
