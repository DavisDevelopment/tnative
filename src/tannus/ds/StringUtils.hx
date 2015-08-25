package tannus.ds;

import tannus.ds.EitherType;
import tannus.io.RegEx;

using StringTools;

/**
  * Class with additional tools for manipulating Strings
  */
class StringUtils {
	/**
	  * Strip out all pieces of [str] which match the pattern [pat]
	  */
	public static function strip(str:String, pat:EitherType<String, EReg>):String {
		switch (pat.type) {
			case Left( repl ):
				return str.replace(repl, '');

			case Right( patt ):
				var res:String = str;
				var reg:RegEx = patt;
				var bits = reg.matches(res);
				for (bit in bits) {
					res = res.replace(bit[0], '');
				}
				return res;
		}
	}

	/**
	  * Place some String on either end of some other
	  */
	public static function wrap(str:String, wrapper:String, ?end:String):String {
		if (end == null)
			end = wrapper;
		return (wrapper + str + end);
	}

	/**
	  * Capitalize some String
	  */
	public static function capitalize(s : String):String {
		return (s.substring(0, 1).toUpperCase() + s.substring(1).toLowerCase());
	}

	/**
	  * Whether sub-string [sub] can be found in [str]
	  */
	public static function has(str:String, sub:String):Bool {
		return (str.indexOf(sub) != -1);
	}

	/**
	  * Array-Style substringing
	  */
	public static function slice(str:String, pos:Int, ?len:Int):String {
		return (len != null ? str.substr(pos, len) : str.substring(pos));
	}
}
