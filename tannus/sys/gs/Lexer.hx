package tannus.sys.gs;

import tannus.io.Byte;
import tannus.io.ByteArray;
import tannus.io.ByteStack;
import tannus.io.Asserts.assert;

import tannus.sys.gs.Token;

using StringTools;
using Lambda;
using tannus.ds.ArrayTools;

class Lexer {
	/* Constructor Function */
	public function new():Void {
		reserved = new Array();
		reset();

		reserve('*{[,:<');
	}

/* === Instance Methods === */

	/**
	  * Tokenize a String, and return the resulting Tokens
	  */
	public function lex(s : String):Array<Token> {
		reset();
		buffer = new ByteStack(ByteArray.ofString( s ));

		while (true) {
			var t:Null<Token> = lexNext();
			if (t == null)
				break;
			else
				tree.push( t );
		}

		return tree;
	}

	/**
	  * Tokenize and return one Token
	  */
	private function lexNext():Null<Token> {
		/* exit immediately if we've reached the end of our input */
		if ( eoi ) {
			return null;
		}

		// the next available Byte
		var c:Byte = next();

		/* == Star and DoubleStar */
		if (c == '*'.code) {
			advance();
			if (!eoi && next() == '*'.code) {
				advance();
				return DoubleStar;
			}
			else {
				return Star;
			}
		}

		/* === Comma === */
		else if (c == ','.code) {
			advance();
			return Comma;
		}

		/* === Bracket Expansion === */
		else if (c == '{'.code) {
			var betw:String = between('{', '}');
			var etree = ilex(betw);
		
			var list:Array<Tree> = [];
			var ct:Tree = [];
			for (tk in etree) {
				switch (tk) {
					case Comma:
						list.push(ct);
						ct = [];

					default:
						ct.push(tk);
				}
			}
			list.push(ct);
			return Expand( list );
		}

		/* == Optional Stuff == */
		else if (c == '['.code) {
			var opt = ilex(between('[', ']'));

			return Optional( opt );
		}

		/* == Colon == */
		else if (c == ':'.code) {
			advance();
			return Colon;
		}

		/* == Parameter Declaration == */
		else if (c == '<'.code) {
			advance();
			var code:String = '';
			while (!eoi && next() != '>'.code)
				code += advance();
			advance();
			var param = ilex( code );
			var name:String = '';
			var check:Token = Star;
			var bits = [param.shift(), param.shift(), param.shift()];
			switch ( bits ) {
				/* only the name is provided */
				case [Literal(sname), null, null]:
					name = sname.trim();

				/* name and pattern are provided */
				case [Literal(sname), Colon, tcheck] if (tcheck != null):
					name = sname;
					check = tcheck;

				/* any other case */
				default:
					throw 'Unexpected $bits';
			}
			return Param(name, check);
		}

		/* == Literal == */
		else {
			var txt:String = c;
			advance();
			while (!eoi && !reserved.has(next())) {
				c = advance();
				txt += c;
			}
			return Literal( txt );
		}
	}

	/**
	  * Lex some String internally, without creating a new Lexer
	  */
	private function ilex(s : String):Tree {
		var current = save();
		tree = new Array();
		var res = lex( s );
		restore( current );
		return res;
	}

	/**
	  * Finds all bytes between a given initiator and delimiter
	  */
	private function between(start:Byte, end:Byte, recursive:Bool=true):String {
		var c:Byte = next();
		var str:String = '';
		if (c == start) {
			advance();
			var lvl:Int = 1;
			while (!eoi && lvl > 0) {
				c = next();
				if (c == start && recursive)
					lvl++;
				else if (c == end)
					lvl--;
				if (lvl > 0)
					str += c;
				advance();
			}
		}
		else {
			throw 'Structure not present!';
		}
		return str;
	}

	/**
	  * Restore [this] Lexer to it's default state
	  */
	private inline function reset():Void {
		buffer = new ByteStack(new ByteArray());
		tree = new Array();
	}

	/**
	  * Get the 'next' Byte in the Buffer
	  */
	private inline function next():Byte {
		return buffer.peek();
	}

	/**
	  * Advance in the buffer by one Byte
	  */
	private function advance():Byte {
		return buffer.pop();
	}

	/**
	  * Mark a Byte as special, not to be considered part of a Literal Token
	  */
	private inline function reserve(set : ByteArray):Void {
		reserved = reserved.concat( set );
	}

	/**
	  * Get the current State of [this] Lexer
	  */
	private function save():State {
		return {
			'buffer': cast buffer.copy(),
			'tree': tree
		};
	}

	/**
	  * Restore to a saved Lexer State
	  */
	private function restore(s : State):Void {
		buffer = s.buffer;
		tree = s.tree;
	}

/* === Computed Instance Fields === */

	/**
	  * Whether the buffer is empty
	  */
	private var eoi(get, never):Bool;
	private inline function get_eoi() return buffer.empty;

/* === Instance Fields === */

	private var buffer : ByteStack;
	private var tree : Array<Token>;
	private var reserved : Array<Byte>;
}

private typedef State = {
	buffer:ByteStack,
	tree:Array<Token>
};
