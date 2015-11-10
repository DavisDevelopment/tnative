package tannus.ds;

import tannus.ds.EitherType;
import tannus.io.RegEx;
import tannus.io.Byte;

using StringTools;

/**
  * Class with additional tools for manipulating Strings
  */
class StringUtils {
	/**
	  * Get the Byte at index [i] in String [s]
	  */
	public static inline function byteAt(s:String, i:Int):Byte {
		if (i <= (s.length - 1)) {
			return new Byte(s.charCodeAt( i ));
		}
		else {
			throw 'IndexOutOfBoundError: $i is not within range(0, ${s.length - 1})';
		}
	}

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
	  * Remove the first instance of [sub] from [str]
	  */
	public static function remove(str:String, sub:String):String {
		var i:Int = str.indexOf(sub);
		if (i == -1)
			return str;
		else if (i == 0)
			return (str.substring(i+sub.length));
		else {
			return (str.substring(0, i) + str.substring(i + 1));
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

	/**
	  * Get all text of [s] that occurs BEFORE [del], or all of [s] if [del] is absent
	  */
	public static function before(s:String, del:String):String {
		if (has(s, del)) {
			return s.substring(0, s.indexOf(del));
		}
		else return s;
	}
	
	/**
	  * get all text of [s] that occurs BEFORE that last instance of [del],
	  * or all of [s] if [del] is absent
	  */
	public static function beforeLast(s:String, del:String):String {
		if (has(s, del)) {
			return (s.substring(0, s.lastIndexOf(del)));
		}
		else {
			return s;
		}
	}

	/**
	  * Get all text of [s] that occurs AFTER [del], or all of [s] if [del] is absent
	  */
	public static function after(s:String, del:String):String {
		if (has(s, del))
			return s.substring(s.indexOf(del)+1);
		else return s;
	}
	
	/**
	  * get all text of [s] that occurs AFTER the last instance of [del]
	  */
	public static function afterLast(s:String, del:String):String {
		if (has(s, del)) {
			return (s.substring(s.lastIndexOf(del) + 1));
		}
		else {
			return '';
		}
	}

	/**
	  * Get last byte of [this] String
	  */
	public static function lastByte(s : String):Byte {
		return new Byte(s.charCodeAt(s.length - 1));
	}

	/**
	  * Test whether the given string is empty
	  */
	public static inline function empty(s : String):Bool {
		return (s.length == 0);
	}
}
