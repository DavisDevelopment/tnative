package tannus.ds;

import tannus.ds.EitherType;
import tannus.io.RegEx;
import tannus.io.Byte;
import tannus.io.Char;
import tannus.ds.tuples.Tup2 in Tuple;

import haxe.macro.Expr;
import haxe.macro.Context;

using StringTools;
using haxe.macro.ExprTools;
using tannus.macro.MacroTools;
using tannus.ds.IteratorTools;
using tannus.FunctionTools;

/**
  * Class with additional tools for manipulating Strings
  */
@:expose( 'StringTools' )
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

	public static function characterAt(s:String, i:Int):Char {
	    if (i <= (s.length - 1)) {
	        return new Char(s.charAt( i ));
	    }
        else {
            throw 'IndexOutOfBoundsError: $i is not within range(0, ${s.length - 1})';
        }
	}

	public static function iterBytes(s: String, pos:Int=0, ?len:Int):Iterator<Byte> {
	    if (len == null) {
	        len = s.length;
	    }
	    return new IntIterator(pos, (pos + len)).map(function(index: Int) return byteAt(s, index));
	}

	/**
	  * Perform byte-by-byte mapping of the given String
	  */
	public static function byteMap(s:String, f:Byte -> Byte):String {
		var res:String = '';
		for (i in 0...s.length) {
			res += f(byteAt(s, i));
		}
		return res;
	}

	/**
	  * macro-licious byteMap
	  */
	public static macro function macbyteMap(s:ExprOf<String>, f:Expr):ExprOf<String> {
		switch ( f.expr ) {
			case EConst(CIdent( '_' )):
				f = (macro char);
			default:
				f = f.mapUnderscoreToExpr(macro char);
		}
		if (!f.hasReturn()) {
			f = (macro return $f);
		}
		f = (macro function(char) $f);
		return macro tannus.ds.StringUtils.byteMap($s, $f);
	}

	/**
	  * Convert the given String from dashed to camel-cased
	  */
	public static function toCamelCase(s:String, sep:String='-'):String {
		var parts = s.split( sep );
		if (parts.length <= 1) {
			return parts.join('');
		}
		var result:String = '';
		result += parts.shift().toLowerCase();
		for (x in parts) {
			result += capitalize( x );
		}
		return result;
	}

	/**
	  * Convert the given String from camel-cased to dash-separated
	  */
	public static inline function toDashed(s : String):String {
		return camelWords( s ).join( '-' );
	}

	/**
	  * Get the words in the given camel-cased String
	  */
	public static function camelWords(s : String):Array<String> {
		var words:Array<String> = new Array();
		var word:String = '';
		for (i in 0...s.length) {
			var c = byteAt(s, i);
			if (c.isUppercase()) {
				words.push( word );
				word = c.aschar.toLowerCase();
			}
			else {
				word += c;
			}
		}
		if (!empty( word )) {
			words.push( word );
		}
		return words;
	}

	/**
	  * Count the number of times that the given pattern is matched in [str]
	  */
	public static function count(str:String, pattern:EitherType<String, EReg>):Int {
		switch ( pattern.type ) {
			case Left( sub ):
				var pos:Int = 0;
				var n:Int = 0;
				var step:Int = sub.length;

				while ( true  ) {
					pos = str.indexOf(sub, pos);
					if (pos >= 0) {
						++n;
						pos += step;

					} else break;
				}
				return n;

			case Right( pat ):
				var e:RegEx = pat;
				return e.matches( str ).length;
		}
	}

    /**
      strip all occurrences of each character in [chars] from [s]
     **/
	public static function trimChars(s:String, chars:String, caseInsensitive:Bool=false):String {
	    for (c in chars.split('')) {
	        s = s.replace(c, '');
	        if (caseInsensitive)
	            s = s.replace(c.toLowerCase(), '');
        }
        return s;
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
	public static function capitalize(s:String, fancy:Bool=false):String {
		if ( !fancy ) {
			return (s.substring(0, 1).toUpperCase() + s.substring(1).toLowerCase());
		}
		else {
			var res:String = '';
			// whether the last Byte was an alphanumeric character
			var lwan:Bool = false;
			for (i in 0...s.length) {
				var c = byteAt(s, i);
				if (c.isAlphaNumeric()) {
					if (c.isLetter()) {
						var l = c.aschar;
						res += (lwan ? l.toLowerCase() : l.toUpperCase());
					}
					else {
						res += c;
					}
					lwan = true;
				}
				else {
					res += c;
					lwan = false;
				}
			}
			return res;
		}
	}

	/**
	  * Whether sub-string [sub] can be found in [str]
	  */
	public static function has(str:String, sub:String):Bool {
		var i:Int;
		try {
			i = str.indexOf( sub );
		}
		catch (err : Dynamic) {
			i = -1;
		}
		return (i != -1);
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
		if (del != '' && has(s, del)) {
			return s.substring(0, s.indexOf(del));
		}
		else return s;
	}
	
	/**
	  * get all text of [s] that occurs BEFORE that last instance of [del],
	  * or all of [s] if [del] is absent
	  */
	public static function beforeLast(s:String, del:String):String {
		if (del != '' && has(s, del)) {
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
		if (del != '' && has(s, del)) {
			return s.substring(s.indexOf( del ) + del.length);
		}
		else {
			return s;
		}
	}
	
	/**
	  * get all text of [s] that occurs AFTER the last instance of [del]
	  */
	public static function afterLast(s:String, del:String):String {
		if (del != '' && has(s, del)) {
			return (s.substring(s.lastIndexOf(del) + del.length));
		}
		else {
			return '';
		}
	}

	/**
	  * separate the given String into a pair of Strings, the String before [sep] and the String after [sep]
	  */
	public static inline function separate(s:String, sep:String, last:Bool=false):Sep {
		return new Sep(
			(last ? beforeLast : before)(s, sep),
			(last ? afterLast : after)(s, sep)
		);
	}

	public static function sep(s:String, sub:String, last:Bool=false):Array<String> {
	    return [
	        (if ( last ) beforeLast else before)(s, sub),
	        (if ( last ) afterLast else after)(s, sub)
	    ];
	}

	public static inline function ifHas<T>(s:String, sub:String, onHas:String->T, onNotHas:String->T):T {
	    if (has(s, sub)) {
	        return onHas( s );
	    }
        else return onNotHas( s );
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

	public static inline function hasContent(s: String):Bool {
	    return (s != null && s.length > 0 && s.trim().length > 0);
	}

	public static inline function ifEmpty(s:String, alt:String):String {
	    return (hasContent( s ) ? s : alt);
	}

	public static inline function nullEmpty(s: String):Null<String> {
	    return (hasContent( s ) ? s : null);
	}

	/**
	  * Repeat a String [count] times
	  */
	public static function times(s:String, count:Int):String {
		if (count == 0) {
			return '';
		}
		else {
			var res:String = s;
			for (i in 0...(--count)) {
				res += s;
			}
			return res;
		}
	}

	/**
	  * determine whether [this] String is made up entirely of numeric characters
	  */
	public static function isNumeric(s : String):Bool {
		for (i in 0...s.length) {
			if (!byteAt(s, i).isNumeric()) {
				return false;
			}
		}
		return true;
	}

	public static function chunk(s: String):Array<String> {
        return (~/\b/g).split(s).filter(x -> !empty(x.trim()));
	}
}

abstract Sep (Pair<String, String>) {
	public inline function new(a:String, b:String):Void {
		this = new Pair(a, b);
	}

	public var before(get, never):String;
	private inline function get_before():String return this.left;

	public var after(get, never):String;
	private inline function get_after():String return this.right;
}
