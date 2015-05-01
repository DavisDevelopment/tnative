package tannus.sys.fquery;

import tannus.sys.fquery.Token;

import tannus.io.Byte;
import tannus.io.ByteArray;

class Parser {
	/* Constructor Function */
	public function new():Void {
		reset();
	}

/* === Instance Methods === */

	/**
	  * Restores [this] Parser back to it's default state
	  */
	private inline function reset():Void {
		tokens = new Array();
		cursor = 0;
	}

/* === Instance Fields === */

	/* The input provided */
	public var input:ByteArray;

	/* The Tokens parsed so far */
	public var tokens:Array<Token>;

	/* The current index */
	public var cursor:Int;
}
