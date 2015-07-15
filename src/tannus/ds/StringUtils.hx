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
}
