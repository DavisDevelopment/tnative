package tannus.sys.gs;

import tannus.io.RegEx;
import tannus.sys.gs.Token;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;

class Printer {
	/* Constructor Function */
	public function new():Void {
		groupCount = 0;
		params = new Map();
	}

/* === Instance Methods === */

	/**
	  * Compile a String
	  */
	public static function compile(s:String, flags:String):{regex:RegEx, params:Map<String, Int>} {
		var p = new Printer();
		var t = (new Lexer()).lex( s );
		return {
			'regex' : p.pattern(t, flags),
			'params': p.params
		};
	}

	/**
	  * Create a RegEx from the given Tree
	  */
	public function pattern(tree:Tree, flags:String=''):RegEx {
		return new EReg(print(tree), flags);
	}

	/**
	  * Convert a Token Tree into a String
	  */
	public function print(tree : Tree):String {
		var s:String = '';
		for (t in tree)
			s += printToken( t );
		return s;
	}

	/**
	  * Convert a single Token into a String
	  */
	public function printToken(t:Token, ?parent:Token):String {
		switch (t) {
			/* == Literal Expression == */
			case Literal( txt ):
				return escape(txt);

			/* == Star == */
			case Star:
				groupCount++;
				return '([^/]+)';

			/* == Double Star == */
			case DoubleStar:
				groupCount++;
				return '(.+)';

			/* == Parameter == */
			case Param(name, check):
				params[name] = groupCount;
				return printToken(check, t);

			/* == Optional == */
			case Optional( tree ):
				groupCount++;
				var sprint = printToken.bind(_, t);
				return tree.map(sprint).join('').wrap('(', ')')+'?';

			/* == Bracket Expansion == */
			case Expand( choices ):
				groupCount++;
				var sprint = printToken.bind(_, t);
				var schoices = [for (c in choices) c.map(sprint).join('')];
				var canBeEmpty:Bool = schoices.remove('');
				var res = schoices.join('|').wrap('(', ')');
				if (canBeEmpty)
					res += '?';
				return res;

			default:
				trace(t + '');
				throw 'SyntaxError: Unexpected $t';
				return '';
		}
	}

	/**
	  * Escape any characters that have special meaning in regular expressions
	  */
	private function escape(txt : String):String {
		var esc:Array<String> = [".", "^", "$", "+", "(", ")", "?"];
		for (c in esc) {
			txt = txt.replace(c, '\\${c}');
		}
		return txt;
	}

/* === Instance Fields === */

	private var groupCount : Int;
	public var params : Map<String, Int>;
}
