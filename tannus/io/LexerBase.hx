package tannus.io;

import tannus.io.Byte;
import tannus.io.ByteArray;
import tannus.io.ByteStack;

class LexerBase {
/* === Instance Methods === */

	/**
	  * Read bytes grouped with grouping symbols
	  */
	private function readGroup(start:Byte, end:Byte, ?esc:Byte, recursive:Bool=true):ByteArray {
		var level:Int = 1;
		var data = new ByteArray();
		var escaped:Bool = false;

		while (!done && level > 0) {
			var c = next();
			if ( !escaped ) {
				if (c == start) {
					if (start != end) level++;
					else level--;
				}
				else if (c == end) level--;
				else if (esc != null && c == esc) {
					escaped = true;
				}
			}
			else {
				escaped = false;
			}
			if (level > 0) data.push( c );
			advance();
		}
		return data;
	}

	/**
	  * Read until the given delimiter
	  */
	private function readUntil(end:Byte, ?esc:Byte):ByteArray {
		var d:ByteArray = new ByteArray();
		var escaped:Bool = false;

		while ( !done ) {
			var c = next();

			if ( !escaped ) {
				if (c == end) {
					advance();
					break;
				}
				else if (esc != null && c == esc) {
					escaped = true;
				}
			}
			else {
				escaped = false;
			}

			d.push(advance());
		}

		return d;
	}

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
