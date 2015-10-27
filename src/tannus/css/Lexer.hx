package tannus.css;

import tannus.io.Byte;
import tannus.io.ByteArray;
import tannus.ds.Stack;
import tannus.css.Token;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;

class Lexer {
	/* Constructor Function */
	public function new():Void {
		reset();
	}

/* === Instance Methods === */

	/**
	  * Parse a String into an Array of Tokens
	  */
	public function tokenize(s : String):Array<Token> {
		reset();
		buffer = new Stack(ByteArray.fromString(s).toArray());

		while (!buffer.empty) {
			var tk:Null<Token> = nextToken();
			if (tk == null) {
				break;
			}
			else
				tokens.push( tk );
		}

		return tokens;
	}

	/**
	  * Find and return the next Token
	  */
	private function nextToken(?prev:Token):Null<Token> {
		if (buffer.empty) {
			return null;
		}
		else {
			var c:Byte = next();

			/* == Whitespace == */
			if (c.isWhiteSpace()) {
				advance();
				return nextToken();
			}

			/* === Variable References === */
			else if (c == '@'.code) {
				advance();
				var state = save();
				var next:Null<Token> = nextToken();
				if (next != null) {
					switch ( next ) {
						/* == Identifier == */
						case TIdent( s ):
							return TRef( s );

						/* == Anything Else == */
						default:
							unexpected( c );
					}
				}
				else {
					unexpected( c );
				}
			}

			/* == Identifiers == */
			else if (isSel(c)) {
				var s:String = '';
				var white:String = '';
				s += c;
				advance();

				//- collect all Bytes that are valid Selector Bytes
				while (!done && isSel(next())) {
					c = advance();
					if (c.isWhiteSpace()) {
						white += c;
					}
					else {
						s += white;
						white = '';
						s += c;
					}
				}
				
				var tk:Token = TIdent( s );

				return tk;
			}

			/* === Blocks === */
			else if (c == '{'.code) {
				//- collect all Bytes between the '{', and the '}'
				var blockBytes:ByteArray = collect('{', '}');

				//- tokenize the contents of the Block
				var tree = sub( blockBytes );

				return TBlock( tree );
			}

			/* === Groups === */
			else if (c == '('.code) {
				//- collect all Bytes between the '(', and the ')'
				var gbytes = collect('(', ')');
				
				//- tokenize the contents of the group
				var tree = sub( gbytes );

				return TParen( tree );
			}

			/* === Semicolon === */
			else if (c == ';'.code) {
				advance();
				return TSemi;
			}

			/* === Colon === */
			else if (c == ':'.code) {
				advance();
				return TColon;
			}

			/* === Comma === */
			else if (c == ','.code) {
				advance();
				return TComma;
			}

			/* === Anything else === */
			else {
				unexpected( c );
			}

			/* useless return so the compiler won't complain */
			return null;
		}
	}

/* === Utility Methods === */

	/**
	  * Determine whether a given Byte is a Selector Byte
	  */
	private function isSel(c : Byte):Bool {
		return (~/[^{}():;,]/.match(c.aschar));
	}

	/**
	  * Collect a group of Bytes
	  */
	private function collect(starter:Byte, stopper:Byte, levelled:Bool=true, ?escaper:ByteArray):ByteArray {
		var res:ByteArray = new ByteArray();
		var level:Int = 0;
		var c = next();
		if (c == starter) {
			advance();
			level++;
			while (!done && level > 0) {
				c = next();
				if (levelled && c == starter) {
					level++;
				}
				
				else if (c == stopper) {
					level--;
				}

				if (level > 0) {
					res.push( c );
				}

				advance();
			}
		}
		return res;
	}

	/**
	  * Split an Array of Tokens by the TComma Token
	  */
	private function splitByComma(toks : Array<Token>):Array<Token> {
		var res:Array<Token> = new Array();
		var last:Null<Token> = null;
		for (t in toks) {
			switch ( t ) {
				case TComma:
					if (last != null) {
						res.push( last );
						last = null;
					}
					else {
						unexpected( ',' );
					}

				default:
					if (last == null)
						last = t;
					else
						unexpected( t );
			}
		}
		if (last != null)
			res.push( last );
		return res;
	}

	/**
	  * Peek at the next Byte
	  */
	private inline function next():Byte {
		return buffer.peek();
	}

	/**
	  * Advance to the next Byte
	  */
	private inline function advance():Byte {
		return buffer.pop();
	}

	/**
	  * get the current State
	  */
	private inline function save():State {
		return {
			'buffer': buffer.copy(),
			'tokens': tokens.copy()
		};
	}

	/**
	  * restore [this] Lexer to the given State
	  */
	private function restore(state : State):Void {
		buffer = state.buffer;
		tokens = state.tokens;
	}

	/**
	  * Tokenize the given String within a 'sub-lexer'
	  */
	private function sub(s : String):Array<Token> {
		var state = save();
		var results:Array<Token> = tokenize( s );
		restore( state );
		return results;
	}

	/**
	  * restore [this] Lexer to it's original State
	  */
	private function reset():Void {
		buffer = new Stack<Byte>([]);
		tokens = new Array();
	}

	/**
	  * Raise a CSSError
	  */
	private inline function err(msg : String):Void {
		#if js
			throw new js.Error('CSSError: $msg');
		#else
			throw 'CSSError: $msg';
		#end
	}

	/**
	  * Raise an Unexpected Error
	  */
	private inline function unexpected(c : Dynamic):Void {
		err('Unexpected $c!');
	}

/* === Computed Instance Fields === */

	/* whether we're at the end of [buffer] */
	private var done(get, never):Bool;
	private inline function get_done():Bool {
		return buffer.empty;
	}

/* === Instance Fields === */

	private var buffer : Stack<Byte>;
	private var tokens : Array<Token>;
}

/**
  * Type to represent the Lexer's current state
  */
private typedef State = {
	var buffer : Stack<Byte>;
	var tokens : Array<Token>;
};
