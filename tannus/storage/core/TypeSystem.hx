package tannus.storage.core;

import tannus.storage.core.TypedValue in Val;
import tannus.storage.core.IndexType;

import tannus.ds.AsyncStack;
import tannus.ds.Dict.Dict;
import tannus.ds.Dict.CDict;
import tannus.ds.Object;
import tannus.ds.EitherType;
import tannus.ds.Maybe;

import tannus.io.ByteArray;
import tannus.io.Ptr;

import Std.*;
import haxe.macro.Expr;
import haxe.macro.Context;

using StringTools;
using Lambda;
using tannus.ds.ArrayTools;
using haxe.macro.ExprTools;

/**
  * Provides utility functions for dealing with the tandb Type System
  */
class TypeSystem {
	
	/**
	  * Convert a Val to a Haxe Type
	  */
	public static function toHaxeType(val : Val):Dynamic {
		switch (val) {
			/* Boolean */
			case TVBool( v ):
				return v;

			/* Float */
			case TVFloat( num ):
				return num;

			/* Int */
			case TVInt( num ):
				return num;

			/* String */
			case TVString( s ):
				return s;

			/* ByteArray */
			case TVBytes( bytes ):
				return bytes;

			/* Date */
			case TVDate( date ):
				return date;

			/* Array */
			case TVArray( vals ):
				return [for (v in vals) toHaxeType(v)];

			/* Dict */
			case TVDict( vdict ):
				//- New Dictionary to hold the converted types
				var res:Dict<String, Dynamic> = new Dict();

				for (row in vdict.iterator()) {
					res[row.key] = toHaxeType( row.value );
				}

				return res;
		}
	}

	/**
	  * Convert a Haxe value to Val
	  */
	public static function fromHaxeType(v : Dynamic):Val {
		/* Boolean */
		if (is(v, Bool))
			return TVBool(cast v);

		/* Float */
		else if (is(v, Float))
			return TVFloat(cast v);

		/* Int */
		else if (is(v, Int))
			return TVInt(cast v);

		/* String */
		else if (is(v, String))
			return TVString(cast v);

		/* Date */
		else if (is(v, Date))
			return TVDate(cast v);

		/* Array */
		else if (is(v, Array)) {
			var list = cast(v, Array<Dynamic>);
			var vals:Array<Val> = [for (sv in list) fromHaxeType(sv)];
			return TVArray( vals );
		}

		/* Dict */
		else if (is(v, CDict) || isAnon(v)) {
			if (is(v, CDict)) {
				var o:Dict<String, Dynamic> = cast v;
				var dict:Dict<String, Val> = new Dict();
				for (row in o) {
					dict[row.key] = fromHaxeType(row.value);
				}
				return TVDict( dict );
			}
			else if (isAnon(v)) {
				var o:Object = v;
				var dict:Dict<String, Val> = new Dict();
				for (k in o.keys) {
					dict[k] = fromHaxeType(o[k]);
				}
				return TVDict( dict );
			}
			else {
				throw 'TypeError: Cannot create a Dict from $v!';
			}
		}

		/* Anything Else */
		else {
			throw 'TypeError: Cannot convert $v to a TanDB Type!';
		}
	}

	/**
	  * Perform type-validation, ensuring that value [val] can be converted to type [type]
	  */
	public static function validate(val:Dynamic, type:IndexType):Bool {
		switch (type) {
			/* Bool */
			case ITBool:
				return is(val, Bool);

			/* Float */
			case ITFloat:
				return is(val, Float);

			/* Int */
			case ITInt:
				return is(val, Int);

			/* String */
			case ITString:
				return is(val, String);

			/* ByteArray */
			case ITBytes:
				if (is(val, Array)) {
					for (x in cast(val, Array<Dynamic>))
						if (!is(x, Int))
							return false;
					return true;
				} else {
					return false;
				}

			/* Date */
			case ITDate:
				return is(val, Date);

			/* Array */
			case ITArray:
				return is(val, Array);

			/* Dict */
			case ITDict:
				return (is(val, CDict) || isAnon(val));
		}
	}

	/**
	  * Convert the given value to the given type
	  */
	public static function convert(value:Dynamic, dtype:EitherType<String, IndexType>):Val {
		var type:IndexType;
		dtype.switchType(s, it, type = typeFromName(s), type = it);

		if (!validate(value, type)) {
			typeErr(value, type);
		}

		switch (type) {
			case ITBool:
				return bool(cast value);

			case ITFloat:
				return float(cast value);

			case ITInt:
				return int(cast value);

			case ITString:
				return string(cast value);

			case ITBytes:
				return bytes(cast value);

			case ITDate:
				return date(cast value);

			case ITArray:
				return array(cast value);

			case ITDict:
				return dict(cast value);
		}
	}

	/**
	  * Throw a Type Error
	  */
	private static inline function typeErr(v:Dynamic, t:IndexType):Void {
		throw 'TypeError: $v cannot to converted to $t!';
	}

	/**
	  * Create a TVBool
	  */
	public static function bool(v : Bool):Val {
		return TVBool( v );
	}

	/**
	  * Create a TVFloat
	  */
	public static function float(v : Float):Val {
		return TVFloat(v);
	}

	/**
	  * Create a TVInt
	  */
	public static function int(v : Int):Val {
		return TVInt( v );
	}

	/**
	  * Create a TVString
	  */
	public static function string(v : String):Val {
		return TVString( v );
	}

	/**
	  * Create a TVBytes
	  */
	public static function bytes(v : ByteArray):Val {
		return TVBytes( v );
	}

	/**
	  * Create a TVDate
	  */
	public static function date(v : Date):Val {
		return TVDate( v );
	}

	/**
	  * Create a TVArray
	  */
	public static function array(list : Array<Dynamic>):Val {
		return TVArray([for (v in list) fromHaxeType(v)]);
	}

	/**
	  * Create a TVDict
	  */
	public static function dict(o : Object):Val {
		var d:Dict<String, Val> = new Dict();
		for (key in o.keys)
			d.set(key, fromHaxeType(o[key]));
		return TVDict( d );
	}

/* === Logical Operator Methods === */

	public static function eq(x:Val, y:Val) return operate('==', x, y);
	public static function ne(x:Val, y:Val) return operate('!=', x, y);
	public static function gt(x:Val, y:Val) return operate('>', x, y);
	public static function ge(x:Val, y:Val) return operate('>=', x, y);
	public static function lt(x:Val, y:Val) return operate('<', x, y);
	public static function le(x:Val, y:Val) return operate('<=', x, y);

	/**
	  * Value in Array
	  */
	public static function vin(val:Val, list:Val):Bool {
		var v:Dynamic = toHaxeType(val);
		switch (list) {
			case TVArray( vals ):
				var arr:Array<Dynamic> = vals.map(toHaxeType);
				return arr.has( v );

			case TVDict( d ):
				var dict:Dict<String, Dynamic> = new Dict(cast toHaxeType(d));
				return dict.exists(cast v);

			default:
				throw 'Cannot perform "IN" clause on $list!';
		}
	}

	/**
	  * List has Value
	  */
	public static function has(list:Val, val:Val):Bool {
		return vin(val, list);
	}


/* === Utility Methods === */

	/**
	  * Do stuff
	  */
	private static macro function operate(op:String, x:Expr, y:Expr):ExprOf<Bool> {
		var code:String = '';
		code += ('toHaxeType('+x.toString()+')');
		code += (' ' + op + ' ');
		code += ('toHaxeType('+y.toString()+')');
		return Context.parse(code, Context.currentPos());
	}

	/**
	  * Get the Type which corresponds to the given type-name
	  */
	public static function typeFromName(name : String):IndexType {
		switch (name.toLowerCase()) {
			case 'bool', 'boolean':
				return ITBool;

			case 'float', 'double':
				return ITFloat;

			case 'int':
				return ITInt;

			case 'string', 'str':
				return ITString;

			case 'bytes', 'bytearray':
				return ITBytes;

			case 'date':
				return ITDate;

			case 'array', 'list':
				return ITArray;

			case 'dict', 'map', 'hash', 'object':
				return ITDict;

			default:
				throw 'TypeError: Unknown type name "${name.toLowerCase()}"!';
		}
	}

	/**
	  * Determine whether [v] is an anonymous Object
	  */
	private static function isAnon(v : Dynamic):Bool {
		if (Reflect.isObject( v )) {
			return (!is(v, Class) && Type.getClass(v) == null);
		}
		else
			return false;
	}
}
