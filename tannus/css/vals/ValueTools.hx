package tannus.css.vals;

import tannus.io.Ptr;
import tannus.io.RegEx;
import tannus.ds.Dict;

import tannus.css.Value;

using Lambda;
using tannus.ds.ArrayTools;

class ValueTools {
	/**
	  * Get the textual representation of a Value
	  */
	public static function toString(v:Null<Value>, vars:Dict<String, Value>, funcs:Dict<String, Array<Value>->Value>):String  {
		if (v == null) {
			throw 'CSSError: Cannot convert a null-Value to String!';
		}
		else switch ( v ) {
			/* Identifier */
			case VIdent(id):
				return id;

			/* String */
			case VString(str):
				return haxe.Json.stringify( str );

			/* Number */
			case VNumber(num, unit):
				var su:String = (unit!=null?unit:'');
				return '$num$su';

			/* Color */
			case VColor( color ):
				return color.toString();

			/* Variable Reference */
			case VRef( name ):
				return toString(vars[name], vars, funcs);

			/* Function Call */
			case VCall(name, args):
				var func:Null<Array<Value>->Value> = funcs[name];
				if (func != null) {
					var val:Value = func( args );
					return toString(val, vars, funcs);
				} 
				else {
					throw 'CSSError: Function $name is not defined';
				}

			default:
				throw 'CSSError: Cannot convert $v to String!';
		}
	}
}
