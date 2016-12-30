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
		if ( buffer.empty ) {
			return null;
		}

		var c:Byte = next();

		/* === Whitespace === */
		if (c.isWhiteSpace()) {
			advance();
			return nextWord();
		}

		/* === Rejected Characters === */
		else if (isWordDelimiter( c ) || isIgnored( c )) {
			advance();
			return nextWord();
		}

		else if (buffer.empty) {
			return null;
		}

		/* === Anything Else === */
		else {
			var str:String = '';
			str += advance();
			while (!buffer.empty && !next().isWhiteSpace() && !isWordDelimiter(next())) {
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
				return new Word(stripOfIgnoredCharacters( str ));
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
	  * Strip the given String of any character that is ignored by [this] Lexer
	  */
	private function stripOfIgnoredCharacters(s : String):String {
		var result:String = '';
		for (i in 0...s.length) {
			var c = s.byteAt( i );
			if (!isIgnored( c )) {
				result += c;
			}
		}
		return result;
	}

	/**
	  * Check whether the given Byte is a non-word character
	  */
	private function isWordDelimiter(c : Byte):Bool {
		return false;
	}
	private function isIgnored(c : Byte):Bool {
		return false;
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
