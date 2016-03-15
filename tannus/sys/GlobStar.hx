package tannus.sys;

import tannus.io.RegEx;
import tannus.io.ByteArray;
import tannus.io.Byte;
import tannus.sys.Path;
import tannus.ds.Object;

import tannus.sys.gs.*;

import haxe.io.Error;

using StringTools;
using tannus.ds.StringUtils;

@:forward
abstract GlobStar (CGlobStar) from CGlobStar {
	public inline function new(s : String, flags:String=''):Void {
		this = new CGlobStar(s, flags);
	}

	@:from
	public static inline function fromString(s:String, flags:String=''):GlobStar {
		return new GlobStar(s, flags);
	}
}

@:expose('globstar')
class CGlobStar {
	/* Constructor Function */
	public function new(pat:String, flags:String):Void {
		spat = pat;
		var data = Printer.compile(pat, flags);
		pattern = data.regex;
		pind = data.params;
	}

/* === Instance Methods === */

	/**
	  * Test a Path against [this] GlobStar
	  */
	public function test(path : String):Bool {
		return pattern.match(path);
		var data = pattern.search( path );
		if (data.length == 0)
			return false;
		else {
			return (path.remove(data[0][0]).trim() == '');
		}
	}

	/**
	  * Get match-data
	  */
	public function match(s : String):Null<Object> {
		var dat = pattern.matches( s );
		if (dat.length == 0)
			return null;
		else {
			var m = dat[0];
			var res:Object = {};
			for (k in pind.keys()) {
				var i = pind[k];
				res[k] = m[i+1];
			}
			return res;
		}
	}

/* === Instance Fields === */

	private var spat : String;
	private var pattern : RegEx;
	private var pind : Map<String, Int>;
	private var printer : Printer;
}

enum Token {
	TLiteral(s : String);
	// TExtract(name : String);
	TExpan(bits : Array<String>);
}
