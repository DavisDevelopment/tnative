package tannus.sys;

import tannus.io.Byte;
import tannus.io.ByteArray;
import tannus.io.Getter;
import tannus.ds.Maybe;

import haxe.io.Bytes;
import haxe.io.Output;

class PyFileOutput extends Output {
	/* Constructor Function */
	public function new(p : String):Void {
		path = p;
		buffer = new ByteArray();
		cursor = 0;
		var op:String->String->Int->Dynamic = (untyped python.Syntax.pythonCode('open', null));

		_fo = op(path, 'wb', 1);
	}

/* === Instance Methods === */

	/* Write the current buffer onto the File */
	override public function flush():Void {
		if (buffer.length > 0) {
			var b = buffer.toPythonByteArray();

			_fo.seek( cursor );
			_fo.write( b );

			buffer = new ByteArray();
		}
	}

	/* Close [this] Output */
	override public function close():Void {
		flush();
		_fo.close();
		cursor = 0;
	}

	/* Move the Cursor */
	public function seek(offset:Int, other:sys.io.FileSeek):Void {
		flush();
		cursor = offset;
	}

	/* Write a Byte of Data onto [this] Output */
	override public function writeByte(b : Int):Void {
		buffer.push( b );
		cursor++;
	}

/* === Instance Fields === */

	/* The Path to the File */
	private var path : String;

	/* ByteArray to Store a Buffer of Data Being Written */
	private var buffer : ByteArray;

	/* The Current 'cursor' */
	private var cursor : Int;

	/* The Python File Object */
	private var _fo : Dynamic;
}
