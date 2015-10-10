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

			pattern = new EReg(code, 'g');
		}
	}

	/**
	  * Parse Replace
	  */
	private function parseReplace(code : String):String {
		var b:ByteArray = code;
		var res:String = '';

		while (b.length > 0) {
			var c:Byte = b.shift();

			/* Optional Hunk */
			if (c == '['.code) {
				var str:String = '';
				while (true) {
					c = b.shift();
					if (c != ']'.code)
						str += c;
					else
						break;
				}
				str = str.replace('*', '[^/]?');
				res += '($str?)';
			}

			else {
				res += c;
			}
		}

		return res;
	}

/* === Instance Fields === */

	private var spat : String;
	private var pattern : RegEx;
}
