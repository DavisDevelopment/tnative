package tannus.css;

import tannus.io.Byte;
import tannus.io.ByteArray;
import tannus.io.ByteStack;
import tannus.ds.Stateful;
import tannus.ds.Stack;
import tannus.css.vals.Lexer.parseString in toval;

import tannus.css.Token;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;

class Lexer implements Stateful<LexerState> {
	/* Constructor Function */
	public function new():Void {
		null;
	}

/* === Instance Methods === */

	/**
	  * tokenize the given input
	  */
	public function tokenize(data : ByteArray):Array<Token> {
		buffer = new ByteStack( data );
		tokens = new Array();

		while ( !done ) {
			var tk = token();
			if (tk != null) {
				tokens.push( tk );
			}
		}

		return tokens;
	}

	/**
	  * attempt to generate the next Token
	  */
	private function token():Null<Token> {
		if ( done ) {
			return null;
		}
		else {
			var c:Byte = next();

			/* == Whitespace == */
			if (c.isWhiteSpace()) {
				advance();
				return token();
			}

			/* == variable declaration == */
			else if (c == '@'.code) {
				advance();
				var name:String = buffer.readUntil( ':' ).toString().trim();
				advance();
				var valtext:String = buffer.readUntil( ';' ).toString().trim();
				advance();
				return TVar(name, toval( valtext ));
			}

			/* == Selectors and Properties == */
			else if (isSel( c )) {
				var str:String = advance();
				var tok:Null<Token> = null;
				while ( !done ) {
					c = next();

					/* block -- this is a ruleset */
					if (c == '{'.code) {
						// [str] is a selector
						var sel:String = str.trim();
						var props = block();
						tok = TRule(sel, props);
					}

					/* this is a property, or a mixin */
					else if (c == ';'.code) {
						if (str.startsWith( '.' )) {
							var name = str.after( '.' );
							tok = TMixin( name );
						}
						else {
							var name = str.before(':').trim();
							var valtext = str.after(':').trim();
							tok = TProp(name, toval( valtext ));
						}
					}

					/* still buffering */
					else {
						str += c;
					}

					advance();

					/* if [tok] has been defined, we're done */
					if (tok != null) {
						break;
					}
				}

				/* complain if [tok] was not found */
				if (tok == null) {
					throw 'Error: unexpected end of input';
				}

				return tok;
			}

			/* anything else */
			else {
				var err = 'Error: unexpected $c';
				trace( err );
				throw err;
			}
		}
	}

	/**
	  * tokenize the Block expression which starts at the current byte
	  */
	private function block():Array<Token> {
		var c:Byte = next();
		if (c == '{'.code) {
			advance();
			var buf:String = '';
			var lvl:Int = 1;
			while (!done && lvl > 0) {
				c = next();
				if (c == '{'.code)
					lvl++;
				else if (c == '}'.code)
					lvl--;
				if (lvl > 0)
					buf += c;
				advance();
			}
			return quickLex( buf );
		}
		else {
			throw 'Error: No block at current position';
			return new Array();
		}
	}

	/* get the current Byte */
	private inline function next(i:Int = 0):Byte return buffer.peek( i );

	/* get the current Byte, and move to the next one */
	private function advance(i:Int = 0):Byte {
		var r = buffer.pop();
		while (i > 0) {
			buffer.pop();
			i--;
		}
		return r;
	}

	/* get the current state of [this] Lexer */
	public inline function getState():LexerState {
		return {
			buffer: cast buffer.copy(),
			tokens: tokens.copy()
		};
	}

	/* set the current state of [this] Lexer */
	public inline function setState(s : LexerState):Void {
		buffer = s.buffer;
		tokens = s.tokens;
	}

	/**
	  * check whether the given Byte is a valid css-selector character
	  */
	private inline function isSel(c : Byte):Bool {
		return ((~/[^{}():;,]/).match( c.aschar ));
	}

/* === Computed Instance Fields === */

	/* whether we've reached the end of input */
	private var done(get, never):Bool;
	private inline function get_done():Bool return buffer.empty;

/* === Instance Fields === */

	private var buffer : ByteStack;
	private var tokens : Array<Token>;

/* === Static Methods === */

	/**
	  * shorthand tokenization
	  */
	public static function quickLex(d : ByteArray):Array<Token> {
		return (new Lexer().tokenize( d ));
	}
}

typedef LexerState = {
	buffer : ByteStack,
	tokens : Array<Token>
};
