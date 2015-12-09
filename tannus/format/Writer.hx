package tannus.format;

import tannus.io.Byte;
import tannus.io.ByteArray;
import tannus.io.Ptr;
import tannus.ds.Maybe;

class Writer {
	/* Constructor Function */
	public function new():Void {
		buffer = ByteArray.alloc( 0 );
	}

/* === Instance Methods === */

	/* Write some data onto [buffer] */
	private inline function w(data : ByteArray) {
		buffer.write( data );
	}

	/* Write some data, followed by a line-break */
	private inline function line(data : ByteArray):Void {
		w( data );
		newline();
	}

	/* Add a line-break to the buffer */
	private inline function newline() w('\n');

	/* Add a tab to the buffer */
	private inline function tab(?n:Int=4) w([for (i in 0...n) ' '].join(''));


/* === Instance Fields === */

	private var buffer : ByteArray;
}
