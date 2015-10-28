package tannus.css.vals;

import tannus.css.Value;
import tannus.io.Byte;
import tannus.io.ByteArray;
import tannus.graphics.Color;

import tannus.css.vals.Unit;

using StringTools;
using Lambda;
using tannus.ds.ArrayTools;
using tannus.ds.StringUtils;

class Lexer {
	/* Constructor Function */
	public function new():Void {
		reset();
	}

/* === Instance Methods === */

	/**
	  * Parse some input
	  */
	public function parse(snip : ByteArray):Array<Value> {
		reset();
		buffer = snip;
		buffer += ' ';

		while (true) {
			try {
				var v:Value = parseNext();
				push( v );
			}
			catch (err : Err) {
				switch (err) {
					case Eof:
						break;

					case Unexpected(c):
						var e:String = 'CSSValueError: Unexpected $c!';
						trace( e );
						throw e;
				}
			}
		}

		return tree;
	}

	/**
	  * Attempt to parse the next Value
	  */
	private function parseNext():Value {
		if (end)
			eof();
		else {
			/* Whitespace */
			if (cur.isWhiteSpace()) {
				advance();
				return parseNext();
			}

			/* Identifiers, References, and Function-Calls */
			else if (cur.isLetter() || cur == '_'.code || cur == '@'.code) {
				var ident:ByteArray = '';
				ident += cur;
				advance();
				while (!end && (cur.isLetter() || cur.isNumeric() || cur == '_'.code)) {
					ident += cur;
					advance();
				}

				/* References */
				if (ident.first == '@'.code) {
					ident.shift();
					return VRef( ident );
				} 
				
				else {
					try {
						var c:Int = cursor;
						var next:Value = parseNext();
						switch (next) {
							/* Function Calls */
							case VTuple( args ):
								return VCall(ident, args);

							/* Identifiers */
							default:
								cursor = c;
								return VIdent( ident );
						}
					} catch (err : Err) switch (err) {
						case Eof:
							return VIdent( ident );

						default:
							throw err;
					}
				}
			}

			/* Numbers */
			else if (cur.isNumeric()) {
				/* Tokenize the Number itself */
				var snum:String = cur.aschar;
				advance();
				while (!end && (cur.isNumeric() || cur == '.'.code)) {
					snum += cur;
					advance();
				}
				/* Parse it as a Float */
				var num:Float = Std.parseFloat( snum );
				var unit:Null<Unit> = null;
				/* If the very next Byte appears to be the beginning of a Unit */
				if (isUnit(cur)) {
					/* Tokenize that Unit */
					var su:String = cur.aschar;
					advance();
					while (!end && isUnit(cur)) {
						su += cur;
						advance();
					}
					/* Assert that what was parsed is, in fact, a valid Unit */
					if (Unit.isValidUnit( su ))
						unit = su;
					/* if not, complain about it */
					else {
						var e:String = 'CSSUnitError: $su is not a valid unit!';
						trace( e );
						throw e;
					}
				}
				/* return the Number */
				return VNumber(num, unit);
			}

			/* Colors */
			else if (cur == '#'.code) {
				var scol:String = '#';
				advance();
				while (!end && ~/[0-9A-F]/i.match(cur.aschar)) {
					scol += cur;
					advance();
				}
				var color:Color = Color.fromString( scol );
				return VColor( color );
			}

			/* Strings */
			else if (cur == '"'.code || cur == "'".code) {
				var del:Byte = cur;
				var str:String = '';
				advance();
				while (!end) {
					/* Escaped Delimiter */
					if (cur == '\\'.code && next() == del) {
						advance();
						str += advance();
					}

					/* Delimiter */
					else if (cur == del) {
						advance();
						break;
					}

					/* String Content */
					else {
						str += cur;
						advance();
					}
				}

				return VString( str );
			}

			/* Tuples */
			else if (cur == '('.code) {
				var stup:ByteArray = '';
				var l:Int = 1;
				advance();
				while (!end && l > 0) {
					switch (cur) {
						case '('.code:
							l++;
						case ')'.code:
							l--;
						default:
							null;
					}
					if (l > 0) {
						stup += cur;
					}
					advance();
				}
				stup += ' ';
				var tup:Array<Value> = [];
				if (!stup.empty) {
					var old = saveState();
					buffer = stup;
					cursor = 0;
					tree = new Array();

					while (!end) {
						var v = parseNext();
						tup.push( v );
						if (cur == ','.code) {
							advance();
						}
						else {
							if (!end) {
								var e:String = 'CSSValueError: Missing ","!';
								throw e;
							}
						}
					}
					loadState( old );
				}
				return VTuple( tup );
			}

			else {
				unex( cur );
			}
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
	  * Save [this] State, and return that save
	  */
	private inline function saveState():State {
		return {
			'buffer': buffer.copy(),
			'tree': tree.copy(),
			'cursor': cursor
		};
	}

	/**
	  * Restore [this] Lexer's state from a saved one
	  */
	private inline function loadState(state : State):Void {
		buffer = state.buffer.copy();
		tree = state.tree.copy();
		cursor = state.cursor;
	}

	/**
	  * Determine whether we are at the end of the Buffer
	  */
	private inline function atend(d:Int=0):Bool {
		return ((cursor + d) == (buffer.length - 1));
	}

	/**
	  * Move forward
	  */
	private function advance(d:Int=1):Byte {
		cursor += d;
		return cur;
	}

	/**
	  * Peek ahead
	  */
	private inline function next(d:Int=1):Byte {
		return (buffer[cursor + d]);
	}

	/**
	  * Add a Value to the Stack
	  */
	private inline function push(v : Value):Void {
		tree.push( v );
	}

/* === Computed Instance FIelds === */

	/**
	  * Whether we're at the end of our Buffer
	  */
	private var end(get, never):Bool;
	private inline function get_end() return atend();

	/**
	  * The current Byte
	  */
	private var cur(get, never):Byte;
	private inline function get_cur() return (buffer[cursor]);

/* === Instance Fields === */

	private var buffer : ByteArray;
	private var cursor : Int;
	private var tree : Array<Value>;

/* === Static Methods === */

	/**
	  * Throw an EOF Error
	  */
	private static inline function eof():Void {
		throw Err.Eof;
	}

	/**
	  * Throw Unexpected Error
	  */
	private static inline function unex(c : Byte):Void {
		throw Err.Unexpected( c );
	}

	/**
	  * Test whether a given Byte is a valid Unit character
	  */
	private static function isUnit(c : Byte):Bool {
		return (c.isLetter() || ['%'.code].has(c.asint));
	}

	/**
	  * Parse a String and return the result
	  */
	public static inline function parseString(s : String):Array<Value> {
		return (new Lexer().parse( s ));
	}
}

private typedef State = {
	var buffer : ByteArray;
	var tree : Array<Value>;
	var cursor : Int;
};

private enum Err {
	Unexpected(c : Byte);
	Eof;
}
