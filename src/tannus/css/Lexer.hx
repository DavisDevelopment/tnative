package tannus.css;

import tannus.io.Byte;
import tannus.io.ByteArray;
import tannus.io.RegEx;
import tannus.io.Signal;
import tannus.ds.Dict;
import tannus.ds.Maybe;

import tannus.css.Token;

using StringTools;
using Lambda;
using tannus.ds.ArrayTools;
using tannus.ds.StringUtils;

/**
  * Class to tokenize css code
  */
class Lexer {
	/* Constructor Function */
	public function new():Void {
		reset();
	}

/* === Instance Methods === */

	/**
	  * Lex [code]
	  */
	public function lex(code : ByteArray):Array<Token> {
		reset();
		buffer = code;

		while (true) {
			try {
				var tk:Token = lexNext();
				push( tk );
			}
			catch (err : Err) {
				switch (err) {
					case Unexpected( c ):
						var e:String = 'CSSSyntaxError: Unexpected $c!';
						trace( e );
						throw e;

					case Eof:
						break;
				}
			}
		}

		//- Push the EOF Token onto the tree
		push( TEof );

		return tree;
	}

	/**
	  * Attempt to find and tokenize the next CSS-Structure in the code
	  */
	private function lexNext():Token {
		//- Ensure that no processing occurs once we've reached the end of our input
		if (end)
			eof();

		var c:Byte = current();
		
		/* if [c] is a white-space character */
		if (c.isWhiteSpace() || c.isLineBreaking()) {
			while (cur.isWhiteSpace())
				advance();
			return lexNext();
		}

		/* Selectors and Property-Definitions */
		else if (~/[@#.\-_A-Z]/i.match(c.aschar)) {
			var sel:ByteArray = (c + '');

			//- Gather all characters of [this] Selector
			while (!end && ~/[_a-zA-Z0-9-#>\[\]. ]/i.match(next().aschar)) {
				advance();
				sel += cur;
			}

			while (sel.last.isWhiteSpace())
				sel.pop();
			
			//- Either pseudo-class, or property-def
			if (nextnw().byte == ':'.code) {
				advance(nextnw().distance);
				var snip:ByteArray = '';
				var ok:Bool = false;
				do {
					if (next() == ';') {
						advance();
						ok = true;
					}
					else if (next() == '{'.code) {
						ok = true;
					}
					else {
						advance();
						snip += cur;
					}
				} while (!end && !ok);
				if (cur == ';'.code) {
					advance();
					var name:String = sel.toString();
					if (name.startsWith('@')) {
						name = name.substring(1);
						return TVar(name, snip.toString().trim());
					} else {
						return TProp(sel, snip.toString().trim());
					}
				}
				else {
					return TSel(sel + ':' + snip.toString().trim());
				}
			}
			else {
				advance();
				return TSel( sel );
			}
		}

		/* Blocks */
		else if (c == '{'.code) {
			var block:String = '';
			var l:Int = 1;

			while (!end && l > 0) {
				switch (next()) {
					case '{'.code:
						l++;

					case '}'.code:
						l--;

					default:
						null;
				}
				if (l > 0)
					block += next();
				advance();
			}
			advance();

			//- Tokenize the contents of [this] Block
			var btree:Array<Token> = (new Lexer().lex( block ));
			//- Eliminate the 'EOF' Token from [this] Block
			btree.pop();
			//- Create and return the Block token
			return TBlock( btree );
		}

		/* Anything Else */
		else {
			unexpected( c );
		}
	}

	/**
	  * Reset [this] Lexer to it's default state
	  */
	private inline function reset():Void {
		buffer = '';
		cursor = 0;
		tree = new Array();
	}

	/**
	  * Determine whether we have reached the end of the Buffer
	  */
	private inline function atend(d:Int=0):Bool {
		return ((cursor + d) == (buffer.length - 1));
	}

	/**
	  * Get the 'current' Byte
	  */
	private inline function current():Byte {
		return (buffer[cursor]);
	}

	/**
	  * "Move" Forward in the Buffer
	  */
	private inline function advance(d:Int=1):Byte {
		cursor += d;
		return current();
	}

	/**
	  * Peek at the 'next' Byte in the Buffer
	  */
	private inline function next(d:Int=1):Null<Byte> {
		return (buffer[cursor + d]);
	}

	/**
	  * Peek at the 'previous' Byte in the Buffer
	  */
	private inline function prev(d:Int=1):Null<Byte> {
		return (buffer[cursor - d]);
	}

	/**
	  * Peek at the next Byte in the Buffer that isn't White-Space
	  */
	private function nextnw():Null<{distance:Int, byte:Byte}> {
		var d:Int = 1;
		while (!atend(d) && next(d).isWhiteSpace()) {
			d++;
		}
		if (atend(d))
			return null;
		else
			return {
				distance: d,
				byte: next(d)
			};
	}

	/**
	  * Push a Token onto the Stack
	  */
	private inline function push(tk : Token):Void {
		tree.push( tk );
	}

/* === Computed Instance Fields === */

	/**
	  * Whether we are at the end of our Buffer
	  */
	private var end(get, never):Bool;
	private inline function get_end() return atend();

	/**
	  * Our current Byte
	  */
	private var cur(get, never):Byte;
	private inline function get_cur() return current();

/* === Instance Fields === */

	/* The code currently being tokenized */
	public var buffer : ByteArray;

	/* The current position in [buffer] */
	private var cursor : Int;

	/* The current token-tree */
	private var tree : Array<Token>;

/* === Static Fields === */

	/**
	  * Throw an EOF (End Of File) Error
	  */
	private static macro function eof() {
		return macro throw Err.Eof;
	}

	/**
	  * Throw an Unexpected [x] Error
	  */
	private static inline function unexpected(b : Byte):Void {
		throw Err.Unexpected( b );
	}

	/**
	  * Determine if a given Byte is a valid Selector-String character
	  */
	private static function isSelector(c : Byte):Bool {
		var patt:RegEx = ~/[^\{\}]/i;
		return (patt.match(c.aschar));
	}
}

/**
  * Enum of errors which [this] Lexer may throw
  */
private enum Err {
	Unexpected(c : Byte);
	Eof;
}
