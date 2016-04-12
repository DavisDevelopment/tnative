package tannus.io;

import tannus.io.ByteArray;
import tannus.io.ByteStack;

class LexerBase {
/* === Instance Methods === */

	/* get the next Byte in [buffer] */
	private inline function next(?dis : Int):Byte {
		return buffer.peek( dis );
	}

	/* advance to the next Byte in [buffer] */
	private inline function advance():Byte return buffer.pop();

/* === Computed Instance Fields === */

	/* whether [buffer] is currently empty or null */
	public var done(get, never):Bool;
	private inline function get_done():Bool return (buffer != null && buffer.empty);

/* === Instance Fields === */

	private var buffer : ByteStack;
}
