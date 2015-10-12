package tannus.format.cfg;

import tannus.io.ByteArray;
import tannus.io.Byte;
import tannus.io.RegEx;

using StringTools;
using Lambda;
using tannus.ds.StringUtils;
using tannus.ds.ArrayTools;

class Parser {
	/* Constructor Function */
	public function new():Void {
		reset();
	}

/* === Instance Methods === */

	/**
	  * Parse a String
	  */
	public function parse(s : String):Array<Token> {
		reset();
		buffer = s;
		buffer.push(13);

		while (!buffer.empty) {
			var tk:Token = token();
			tokens.push( tk );
		}

		return tokens;
	}

	/**
	  * Get the next token
	  */
	private function token():Token {
		var c:Byte = pop();

		/* non-line-breaking whitespace */
		if (c.isWhiteSpace() && !c.isLineBreaking()) {
			spaced = true;
			return token();
		}

		/* line-break */
		else if (c.isLineBreaking()) {
			var prev:Null<Token> = tokens.pop();
			if (prev != null) {
				switch (prev) {
					case TStop:
						null;

					default:
						tokens.push( prev );
				}
			}
			spaced = true;
			return TStop;
		}

		/* identifier */
		else if (c.isLetter() || c == "$".code) {
			var id:String = '';
			do {
				id += c;
				c = pop();
			}
			while (c.isAlphaNumeric() || (c == '_' || c == '-'));
			push( c );
			var tk:Token;
			if (id.startsWith("$")) {
				tk = TConst(CRef(id.after("$")));
			}
			else {
				tk = TConst(CIdent( id ));
			}
			if (!spaced) {
				var prev:Token = tokens.pop();
				if (prev != null) {
					switch (prev) {
						case TConst(CNumber(n, null)):
							tk = TConst(CNumber(n, id));

						default:
							tokens.push(prev);
					}
				}
			}
			spaced = false;
			return tk;
		}

		/* numbers */
		else if (c.isNumeric()) {
			var snum:String = '';
			while (c.isNumeric() || (c == '.'.code)) {
				snum += c;
				c = pop();
			}
			push( c );
			spaced = false;
			return TConst(CNumber(Std.parseFloat(snum)));
		}

		/* strings */
		else if (c == '"'.code || c == "'".code) {
			var del:Byte = c;
			var str:String = '';
			var escaped:Bool = false;
			while (true) {
				c = pop();
				if (c == del.asint) {
					if (!escaped)
						break;
					else {
						str += c;
						escaped = false;
					}
				}
				else if (c == '\\'.code) {
					escaped = !escaped;
				}
				else
					str += c;
			}
			spaced = false;
			return TConst(CString(str));
		}

		/* flags and calls */
		else if (c == '-'.code) {
			var line:Array<Token> = new Array();

			while (true) {
				var t = token();
				switch (t) {
					case TStop:
						break;

					default:
						line.push( t );
				}
			}
			var first = line.shift();
			var tk:Null<Token> = null;
			switch (first) {
				case TConst(CIdent(name)):
					spaced = false;
					tk = (line.length == 0 ? TFlag : TCall.bind(_, line))( name );
					if (isStruct( tk )) {
						tk = toStruct(tk);
					}

				default:
					throw 'SyntaxError: Unexpected $first!';
			}
			if (tk != null) {
				return tk;
			}
			else {
				throw 'WutTheFuck: Token should not be null';
			}
		}

		else {
			return token();
		}
	}

	/**
	  * Check whether the given Token is a Structure
	  */
	private function isStruct(t : Token):Bool {
		var structNames:Array<String> = [
			'set'
		];

		switch ( t ) {
			case TCall(name, _):
				return structNames.has(name);

			default:
				return false;
		}
	}

	/**
	  * Convert to a structure
	  */
	private function toStruct(t : Token):Token {
		switch ( t ) {
			case TCall(name, args):
				switch ( name ) {
					/* variable assignment */
					case 'set':
						switch (args) {
							/* valid variable assignment */
							case [TConst(CIdent(vname)), value]:
								return TVar(vname, value);

							/* invalid variable assignment */
							default:
								throw 'SyntaxError: invalid variable assignment';
						}

					default:
						throw 'WutTheFuck: $name is not a structure';
				}

			default:
				throw 'WutTheFuck: $t is not a structure';
		}
	}

	/**
	  * Reset the state of [this] Parser
	  */
	private inline function reset():Void {
		tokens = new Array();
		spaced = false;
	}

	/* get the next Byte */
	private inline function pop():Byte {
		return buffer.shift();
	}

	/* put a Byte back */
	private inline function push(v : Byte):Void {
		buffer.unshift( v );
	}

/* === Instance Fields === */

	private var tokens : Array<Token>;
	private var buffer : ByteArray;
	private var spaced : Bool;
}

enum Token {
	TFlag(name : String);
	TCall(name:String, args:Array<Token>);
	TVar(name:String, value:Token);
	TConst(c : Const);

	//- line-break
	TStop;
}

enum Const {
	CNumber(n:Float, ?unit:String);
	CString(s : String);
	CIdent(s : String);
	CRef(name : String);
}
