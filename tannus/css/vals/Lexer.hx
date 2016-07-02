package tannus.css.vals;

import tannus.css.Value;
import tannus.io.Byte;
import tannus.io.ByteArray;
import tannus.io.ByteStack;
import tannus.graphics.Color;

import tannus.css.vals.Unit;

using StringTools;
using Lambda;
using tannus.ds.ArrayTools;
using tannus.ds.StringUtils;

@:expose
class Lexer {
	/* Constructor Function */
	public function new():Void {
		//reset();
	}

/* === Instance Methods === */

	/**
	  * Parse some input
	  */
	public function parse(snip : ByteArray):Array<Value> {
		buffer = new ByteStack( snip );
		tree = new Array();

		while ( !end ) {
			var val = parseNext();
			if (val != null)
				push( val );
		}

		return tree;
	}

	/**
	  * Attempt to parse the next Value
	  */
	private function parseNext():Null<Value> {
		if ( end ) {
			return null;
		}

		var c = next();
		/* Whitespace */
		if (c.isWhiteSpace()) {
			advance();
			return parseNext();
		}

		/* Identifiers, References, and Function-Calls */
		else if (c.isLetter() || c == '_'.code || cur == '@'.code) {
			var ident:String = advance();
			while (!end && (next().isLetter() || next().isNumeric() || next().equalsChar('_'))) {
				ident += advance();
			}

			/* References */
			if (ident.startsWith( '@' )) {
				ident = ident.after( '@' );
				return VRef( ident );
			} 
			
			else {
				if ( end ) {
					return VIdent( ident );
				}
				c = next();
				if (c == '('.code) {
					return VCall(ident, tuple());
				}
				else {
					return VIdent( ident );
				}
			}
		}

		/* Numbers */
		else if (c.isNumeric()) {
			/* Tokenize the Number itself */
			var snum:String = advance();
			while (!end && (next().isNumeric() || next().equalsChar('.'))) {
				snum += advance();
			}

			/* Parse it as a Float */
			var num:Float = Std.parseFloat( snum );
			var unit:Null<Unit> = null;
			
			/* If the very next Byte appears to be the beginning of a Unit */
			if (!end && isUnit(next())) {
				/* Tokenize that Unit */
				var su:String = advance();
				while (!end && isUnit(next())) {
					su += advance();
				}
				/* Assert that what was parsed is, in fact, a valid Unit */
				if (Unit.isValidUnit( su ))
					unit = su;
				/* if not, complain about it */
				else {
					var e:String = 'CSSUnitError: $su is not a valid unit!';
					throw e;
				}
			}

			/* return the Number */
			return VNumber(num, unit);
		}

		/* Colors */
		else if (c == '#'.code) {
			var scol:String = advance();
			while (!end && ~/[0-9A-F]/i.match(next())) {
				scol += advance();
			}
			var color:Color = Color.fromString( scol );
			return VColor( color );
		}

		/* Strings */
		else if (c == '"'.code || c == "'".code) {
			var del:Byte = c;
			var str:String = '';
			advance();
			c = next();
			while ( !end ) {
				/* Delimiter */
				if (c == del) {
					advance();
					break;
				}

				/* String Content */
				else {
					str += cur;
					advance();
				}

				c = next();
			}

			return VString( str );
		}

		/* Commas */
		else if (c == ','.code) {
			advance();
			return VComma;
		}

		else {
			unex( cur );
			return Value.VNumber( 0 );
		}
	}

	/**
	  * parse a tuple into an array of values
	  */
	private function tuple():Array<Value> {
		var c = next();
		var str:String = '';
		var lvl:Int = 1;
		advance();
		while (lvl > 0) {
			c = next();
			if (c == '('.code)
				lvl++;
			else if (c == ')'.code)
				lvl--;
			if (lvl > 0) {
				str += c;
			}
			advance();
		}
		var sublexer = new Lexer();
		var subvals = sublexer.parse( str );
		var tupvals:Array<Value> = new Array();
		var tmp:Null<Value> = null;

		for (sv in subvals) {
			switch ( sv ) {
				case VComma:
					if (tmp != null) {
						tupvals.push( tmp );
						tmp = null;
					}
					else {
						throw 'Error: unexpected ,';
					}
				default:
					if (tmp == null) {
						tmp = sv;
					}
					else {
						throw 'Error: missing ,';
					}
			}
		}

		if (tmp != null)
			tupvals.push( tmp );
		return tupvals;
	}

	/**
	  * Save [this] State, and return that save
	  */
	private inline function saveState():State {
		return {
			'buffer': cast buffer.copy(),
			'tree': tree.copy()
		};
	}

	/**
	  * Restore [this] Lexer's state from a saved one
	  */
	private inline function loadState(state : State):Void {
		buffer = state.buffer;
		tree = state.tree;
	}

	/**
	  * Move forward
	  */
	private function advance(d:Int=0):Byte {
		var r = buffer.pop();
		while (d > 0) {
			d--;
			buffer.pop();
		}
		return r;
	}

	/**
	  * Peek ahead
	  */
	private inline function next(d:Int=0):Byte return buffer.peek( d );

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
	private inline function get_end() return buffer.empty;

	/**
	  * The current Byte
	  */
	private var cur(get, never):Byte;
	private inline function get_cur() return buffer.peek();

/* === Instance Fields === */

	private var buffer : ByteStack;
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
	var buffer : ByteStack;
	var tree : Array<Value>;
};

private enum Err {
	Unexpected(c : Byte);
	Eof;
}
