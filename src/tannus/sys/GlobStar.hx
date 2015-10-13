package tannus.sys;

import tannus.io.RegEx;
import tannus.io.ByteArray;
import tannus.io.Byte;
import tannus.sys.Path;

import haxe.io.Error;

using StringTools;
using tannus.ds.StringUtils;

@:forward
abstract GlobStar (CGlobStar) from CGlobStar {
	public inline function new(s : String):Void {
		this = new CGlobStar(s);
	}

	@:from
	public static inline function fromString(s : String):GlobStar {
		return new GlobStar(s);
	}
}

@:expose('globstar')
class CGlobStar {
	/* Constructor Function */
	public function new(pattern : String):Void {
		spat = pattern;

		compile();
	}

/* === Instance Methods === */

	/**
	  * Test a Path against [this] GlobStar
	  */
	public function test(path : Path):Bool {
		return pattern.match(path.normalize().str);
	}

	/**
	  * Compile [this] GlobStar
	  */
	private function compile():Void {
		var code:String = spat;
		var escaped:Array<String> = [".", "^", "$", "+", "(", ")", "?"];
		for (c in escaped)
			code = code.replace(c, '\\${c}');
		code = parseReplace(code);
		if (!code.has('*') && !code.has("?")) {
			pattern = new EReg(code, 'g');
			return ;
		}
		else {
			var single:String = '([^/]+)';
			var double:String = '(.+)';

			code = code.replace('**', double);
			code = code.replace('*', single);
			code = code.wrap('^', '$');

			pattern = new EReg(code, 'g');
		}
	}

	/**
	  * Parse Replace
	  */
	private function parseReplace(code : String):String {
		var tokens = parse( code );
		var res:String = '';

		for (t in tokens) {
			switch (t) {
				case TLiteral(s):
					res += s;

				case TExpan(bits):
					res += bits.map(function(s) return s.wrap('(', ')')).join('|').wrap('(',')');
			}
		}

		return res;
	}

	/**
	  * parse the globstar
	  */
	private function parse(code : String):Array<Token> {
		var b:ByteArray = code;
		var tokens:Array<Token> = new Array();

		var buf:String = '';

		while (b.length > 0) {
			var c:Byte = b.shift();

			if (c == '{'.code) {
				tokens.push(TLiteral(buf));
				buf = '';
				var bits = new Array();
				while (true) {
					c = b.shift();
					if (c == ','.code) {
						bits.push(buf);
						buf = '';
						continue;
					}
					else if (c == '}'.code) {
						bits.push(buf);
						buf = '';
						break;
					}
					else {
						buf += c;
					}
				}
				tokens.push(TExpan( bits ));
			}

			else {
				buf += c;
			}
		}
		tokens.push(TLiteral(buf));
		buf = '';

		return tokens;
	}

/* === Instance Fields === */

	private var spat : String;
	private var pattern : RegEx;
}

enum Token {
	TLiteral(s : String);
	// TExtract(name : String);
	TExpan(bits : Array<String>);
}
