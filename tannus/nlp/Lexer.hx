package tannus.nlp;

import tannus.io.Byte;
import tannus.io.ByteArray;
import tannus.io.ByteStack;

import tannus.ds.Stack;

using tannus.ds.StringUtils;

class Lexer {
	/* Constructor Function */
	public function new():Void {

	}

/* === Instance Methods === */

	/**
	  * Tokenize the given String
	  */
	public function tokenize(s : String):Array<Word> {
		buffer = new ByteStack(ByteArray.ofString( s ));
		words = new Array();

		while (!buffer.empty) {
			var w:Null<Word> = nextWord();
			if (w == null)
				break;
			else
				words.push( w );
		}

		return words;
	}

	/**
	  * Tokenize the next Word in the Stack
	  */
	private function nextWord():Null<Word> {
		var c:Byte = next();

		/* === Whitespace === */
		if (c.isWhiteSpace()) {
			advance();
			return nextWord();
		}

		/*
		else if (c == '('.code) {
			advance();
			var lvl = 1;
			while (!buffer.empty && lvl > 0) {
				c = next();
				if (c == '('.code)
					lvl++
			}
		}
		*/

		else if (buffer.empty) {
			return null;
		}

		/* === Anything Else === */
		else {
			var str:String = '';
			str += advance();
			while (!buffer.empty && !next().isWhiteSpace()) {
				str += advance();
			}
			var hasletter:Bool = false;
			for (i in 0...str.length) {
				if (str.byteAt(i).isLetter()) {
					hasletter = true;
					break;
				}
			}
			if (hasletter) {
				return new Word( str );
			}
			else if (buffer.empty) {
				return null;
			}
			else {
				return nextWord();
			}
		}
	}

	/**
	  * Peek at the next Byte in the Stack
	  */
	private inline function next():Byte return buffer.peek();

	/**
	  * Advance to the next Byte in the Stack
	  */
	private inline function advance():Byte return buffer.pop();

/* === Instance Fields === */

	private var buffer : ByteStack;
	private var words : Array<Word>;

/* ==== Static Fields === */

	/**
	  * Shorthand to Tokenize a String
	  */
	public static function tokenizeString(s : String):Array<Word> {
		return (new Lexer()).tokenize( s );
	}
}
