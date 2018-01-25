package tannus.ds;

import tannus.ds.Object;
import tannus.ds.Maybe;
import tannus.io.RegEx;
import tannus.io.ByteArray;
import tannus.io.Byte;
import tannus.io.Asserts.assert;
import tannus.internal.TypeTools.typename in tn;
import Std.*;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;

class QueryString {
	/**
	  * Generate a QueryString
	  */
	public static function stringify(data : Object):String {
		var pairs:Array<String> = new Array();

		for (key in data.keys) {
			var val:Dynamic = data[key].value;
			var t:String = tn( val );
			switch ( t ) {
				case 'Number', 'String', 'Boolean':
					pairs.push(key + '=' + enc( val ));

				case 'Array':
					var arr:Array<Dynamic> = cast val;
					arr.iter(function(x) {
					    assert(['Number', 'String', 'Boolean'].has(tn( x )), 'TypeError: Cannot urlify non-primitive values!');
                    });
					for (x in arr) {
						pairs.push('$key[]=' + enc( x ));
					}

				default:
					var o:Object = new Object(val);
					for (ok in o.keys) {
						pairs.push('$key[$ok]=' + enc(o[ok]));
					}
			}
		}
		var qs:String = pairs.join('&');
		return qs;
	}

	/**
	  * string-encode a value
	  */
	private static function enc(value : Dynamic):String {
		var s = string( value ).urlEncode();
		s = s.replace('%2B', '+');
		s = s.replace('%0D', '');
		return s;
	}

	/**
	  * Parse a QueryString back into an object
	  */
	public static function parse(qs : String):Object {
		var ekey:RegEx = ~/([A-Z]+[A-Z0-9_\-]*)\[([A-Z]+[A-Z0-9]*)\]/i;
		var earr:RegEx = ~/([A-Z]+[A-Z0-9_\-]*)\[([0-9]*)\]/i;

		var res:Object = {};
		var pairs = qs.split('&').map(function(s) return (s.split('=')));
		for (p in pairs) {
			switch (p) {
				case [_.urlDecode() => key, _.urlDecode() => val] if (ekey.match(key)):
					var md = ekey.search(key)[0].slice(1);
					key = md[0];
					var okey:String = md[1];
					if (!res.exists(key))
						res[key] = {};
					(new Object(res[key])).set(okey, val);

				case [_.urlDecode() => key, _.urlDecode() => val] if (earr.match(key)):
					var md = earr.search(key)[0].slice(1);
					key = md[0];
					var index:Null<Int> = parseInt(md[1]);
					if (!res.exists(key))
						res[key] = new Array<Dynamic>();

					var list = cast(res[key].value, Array<Dynamic>);
					if (index != null)
						list[index] = val;
					else
						list.push( val );

				case [_.urlDecode() => key, _.urlDecode() => val]:
					res[key] = val;
			}
		}

		return res;
	}
}
