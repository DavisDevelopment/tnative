package tannus.css.vals;

import tannus.io.Ptr;
import tannus.io.RegEx;
import tannus.ds.Dict;

import tannus.css.Value;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;

class ValueTools {
	/**
	  * Get the textual representation of a Value
	  */
	public static function toString(v : Null<Value>):String  {
		if (v == null) {
			throw 'CSSError: Cannot convert a null-Value to String!';
		}
		else switch ( v ) {
			/* Identifier */
			case VIdent( id ):
				return id;

			/* String */
			case VString( str ):
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
				//return toString(vars[name], vars, funcs);
				return '@$name';

			/* Function Call */
			case VCall(name, args):
				/*
				var func:Null<Array<Value>->Value> = funcs[name];
				if (func != null) {
					var val:Value = func( args );
					return toString(val, vars, funcs);
				} 
				else {
					throw 'CSSError: Function $name is not defined';
				}
				*/
				var sargs = args.macmap(toString( _ )).join(', ');
				return '$name($sargs)';

			default:
				throw 'CSSError: Cannot convert $v to String!';
		}
	}

	/**
	  * extract an integer value from the given Value
	  */
	public static function toInt(v : Value):Null<Int> {
		switch ( v ) {
			case VNumber(n, _):
				return Std.int( n );
			case VString( s ):
				return Std.parseInt( s );
			default:
				return null;
		}
	}

	public static function toBool(v : Value):Null<Bool> {
		switch ( v ) {
			case VIdent( s ):
				if (~/true|false|yes|no|on|off/i.match( s )) {
					return switch (s.toLowerCase()) {
						case 'true','yes','on': true;
						case 'false', 'no', 'off': false;
						default: null;
					};
				}
				else {
					return null;
				}
			default:
				return null;
		}
	}

	/**
	  * Apply function [predicate] to every sub-Value of the given Value
	  */
	public static function iter(value:Value, predicate:Value -> Void):Void {
		predicate( value );
		switch ( value ) {
			case VCall(_, args):
				for (v in args) {
					iter(v, predicate);
				}

			default:
				null;
		}
	}

	/**
	  * transform the given Value using the given mapper function, and return the result
	  */
	public static function map(value:Value, mapper:Value -> Value):Value {
		var val:Value = value;
		switch ( value ) {
			case VCall(name, args):
				val = VCall(name, args.macmap(map(_, mapper)));

			default:
				null;
		}
		val = mapper( val );
		return val;
	}
}
