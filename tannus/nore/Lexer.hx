package tannus.nore;

import tannus.io.Byte;
import tannus.io.ByteArray;
import tannus.io.ByteStack;
import tannus.ds.Stack;
import tannus.io.Asserts.assert;

import tannus.nore.Token;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;

class Lexer {
	/* Constructor Function */
	public function new():Void {
		reset();
		operators = new Array();

		operator( '=>' );
		operator( 'is' );
		operator( 'has' );
		operator( 'contains' );
	}

/* === Instance Methods === */

	/**
	  * Add an operator to [this]'s registry
	  */
	public inline function operator(op : String):Void {
		operators.push( op );
	}

	/**
	  * Tokenize the given String
	  */
	public function lex(s : String):Array<Token> {
		reset();
		bytes = new ByteStack(ByteArray.ofString( s ));

		while ( !end ) {
			var t:Null<Token> = lexNext();
			if (t != null) {
				tokens.push( t );
			}
		}

		return tokens;
	}

	/**
	  * Attempt to tokenize the next Token
	  */
	private function lexNext():Null<Token> {
		var c:Byte = next();

		/* == whitespace == */
		if (c.isWhiteSpace()) {
			advance();
			if ( !end )
				return lexNext();
			else
				return null;
		}

		/* == identifiers == */
		else if (c.isLetter() || c == '_'.code) {
			var id:String = c;
			advance();
			while (!end && isIdent(next())) {
				id += advance();
			}
			if (isOperator( id )) {
				return TOperator( id );
			}
			if (isKeyword( id )) {
				return lexStructure(id.toLowerCase());
			}
			else {
				return TConst(CIdent( id ));
			}
		}

		/* == references == */
		else if (c == '@'.code) {
			advance();
			var id:String = '';
			while (!end && isIdent(next())) {
				id += advance();
			}
			return TConst(CReference( id ));
		}

		/* == Strings and shit == */
		else if (['"'.code, "'".code, '`'.code].has(c)) {
			var delimiter:Byte = advance();
			var level:Int = (switch (delimiter) {
				case "'".code: 1;
				case '"'.code: 2;
				case '`'.code: 3;
				default: -1;
			});
			var str:String = bytes.readUntil( delimiter );
			advance();
			return TConst(CString(str, level));
		}

		/* == Numbers == */
		else if (c.isNumeric()) {
			var snum:String = advance();
			while (!end && (next().isNumeric() || next() == '.')) {
				snum += advance();
			}
			return TConst(CNumber(Std.parseFloat(snum)));
		}

		/* == Bracketed Groups == */
		else if (c == '['.code) {
			var sgroup:String = readGroup('[', ']');
			var group = sub( sgroup );
			return TBrackets( group );
		}

		/* == Boxed Groups == */
		else if (c == '{'.code) {
			var sg:String = readGroup('{', '}');
			var g = sub( sg );
			return TBoxBrackets( g );
		}

		/* === Operators === */
		else if (isOpChar(c)) {
			var state = save();
			var op:String = advance();
			while (!end && isOpChar(next())) {
				op += advance();
			}
			if (isOperator( op )) {
				return TOperator( op );
			}
			else {
				switch ( op ) {
					case '!':
						return TNot;

					default:
						throw 'SyntaxError: Invalid operator "$op"!';
						return null;
				}
			}
		}

		/* == Tuples == */
		else if (c == '('.code) {
			/* == Tokenize the Tuple == */
			var s:ByteArray = readGroup('(', ')');
			var toklist:Array<Token> = (s.empty ? [] : sub(s.toString()));
			var treeStack:Stack<Token> = new Stack(toklist.copy());
			var tree:Array<Token> = new Array();
			var hasComma:Bool = false;
			while (!treeStack.empty) {
				var t:Token = treeStack.pop();
				if (!t.match(TComma)) {
					tree.push( t );
				}
				else {
					hasComma = true;
				}
			}

			if ( hasComma ) {
				return TTuple( tree );
			}
			else {
				return TGroup( toklist );
			}
		}

		/* == Commas == */
		else if (c == ','.code) {
			advance();
			return TComma;
		}

		/* == OR (|) == */
		else if (c == '|'.code) {
			advance();
			return TOr;
		}

		/* == Colon == */
		else if (c == ':'.code) {
			advance();
			canCall = true;
			var name:Null<Token> = lexNext();
			switch ( name ) {
				case TConst(CIdent(name)):
					if ( !end ) {
						var state = save();
						var targs:Null<Token> = lexNext();
						switch ( targs ) {
							case TTuple( args ):
								trace('helper');
								return THelper(name, args);

							case TGroup(_[0] => arg):
								trace('helper');
								return THelper(name, [arg]);

							default:
								restore( state );
								trace('helper');
								return THelper(name, []);
						}
					}
					else {
						trace('helper');
						return THelper(name, []);
					}

				default:
					throw 'SyntaxError: Expected identifier, got $name';
			}
		}

		/* == .. operator == */
		else if (c == '.'.code) {
			advance();
			if (next() == '.'.code) {
				advance();
				return TDoubleDot;
			}
			else {
				throw 'SyntaxError: Expected ".", got ${next()}';
			}
		}

		/* == ~ operator == */
		else if (c == '~'.code) {
			advance();
			return TApprox;
		}

		/* == anything else == */
		else {
			throw 'SyntaxError: Unexpected "$c"!';
		}
	}

	/**
	  * Tokenize a structure
	  */
	private function lexStructure(kw : String):Token {
		switch ( kw ) {
			/* == if statement == */
			case 'if':
				var cond = lexNext();
				trace( cond );
				var then = lexNext();
				trace( then );
				switch ( then ) {
					case TConst(CIdent('then')):
						var itrue = lexNext();
						trace( itrue );
						var ifalse = null;
						if ( !end ) {
							var state = save();
							var otherwise = lexNext();
							switch ( otherwise ) {
								case TConst(CIdent('else')):
									ifalse = lexNext();
									trace( ifalse );

								default:
									restore( state );
							}
						}
						assert(cond != null, 'SyntaxError: Unexpected if!');
						assert(itrue != null, 'SyntaxError: Unexpected end of input!');
						return TIf(cond, itrue, ifalse);

					default:
						throw 'SyntaxError: Unexpected $then!';
				}
			/* == A Fuck-Up Has Occurred == */
			default:
				throw 'FuckUpError: "$kw" is not a keyword';
		}
	}

	/**
	  * Read a group
	  */
	private function readGroup(start:Byte, end:Byte):ByteArray {
		var c:Byte = next();
		if (c == start) {
			var level:Int = 1;
			var data:ByteArray = new ByteArray();
			advance();
			while (level > 0) {
				c = next();
				if (c == start) {
					level++;
				}
				else if (c == end) {
					level--;
				}

				if (level > 0) {
					data.push( c );
				}
				advance();
			}
			return data;
		}
		return new ByteArray();
	}

	/**
	  * Tokenize a sub-tree
	  */
	private function sub(s : String):Array<Token> {
		var state = save();
		var _it:Bool = inTernary;
		var result = lex( s );
		restore( state );
		inTernary = _it;
		return result;
	}

	/**
	  * Reset [this] to it's default state
	  */
	private inline function reset():Void {
		tokens = new Array();
		canCall = false;
		inTernary = false;
		bytes = new ByteStack(new ByteArray());
	}

	/**
	  * Get the current state of [this]
	  */
	private function save():State {
		return {
			'tokens' : tokens.copy(),
			'bytes' : cast bytes.copy(),
			'canCall' : canCall
		};
	}

	/**
	  * Restore [this] to a previous State
	  */
	private function restore(s : State):Void {
		bytes = s.bytes;
		tokens = s.tokens;
		canCall = s.canCall;
	}

	/**
	  * Peek at the 'next' Byte in the stack
	  */
	private inline function next():Byte {
		return bytes.peek();
	}

	/**
	  * advance to the next Byte in the stack
	  */
	private inline function advance():Byte {
		return bytes.pop();
	}

	/**
	  * Get the last-lexed Token
	  */
	private inline function last():Null<Token> {
		return tokens.pop();
	}

	/**
	  * determine whether [c] is an identifier character
	  */
	private function isIdent(c : Byte):Bool {
		return (c.isAlphaNumeric() || c == '.'.code || c == '_'.code);
	}

	/**
	  * determine whether [c] is an operator character
	  */
	private function isOpChar(c : Byte):Bool {
		return [
			'=', '!', '<', '>',
			"$", '^'
		].has(c.aschar);
	}

	/**
	  * determine whether [op] is an operator
	  */
	private inline function isOperator(op : String):Bool {
		return operators.has( op );
	}

	/**
	  * determine whether [id] is a keyword
	  */
	private inline function isKeyword(id : String):Bool {
		return [
			'if'
		].has(id.toLowerCase());
	}

/* === Computed Instance Fields === */

	/* whether we're at the end of our input */
	private var end(get, never):Bool;
	private inline function get_end():Bool return bytes.empty;

/* === Instance Fields === */

	private var bytes : ByteStack;
	private var tokens : Array<Token>;
	private var operators : Array<String>;
	private var canCall : Bool;
	private var inTernary : Bool;

/* === Static Methods === */

	/**
	  * Shorthand to tokenize a String
	  */
	public static inline function lexString(s : String):Array<Token> {
		return (new Lexer().lex( s ));
	}
}

private typedef State = {
	var tokens : Array<Token>;
	var bytes : ByteStack;
	var canCall : Bool;
};
