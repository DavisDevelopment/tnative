package tannus.nore;

import tannus.io.Getter;

using StringTools;
using Lambda;
using tannus.ds.StringUtils;
using tannus.ds.ArrayTools;

class ValueTools {
	/**
	  * Create a Value from a Token
	  */
	public static function toValue(t : Token):Value {
		switch ( t ) {
			/* Strings */
			case TConst(CString(str, _)):
				return VString( str );

			/* Numbers */
			case TConst(CNumber( num )):
				return VNumber( num );

			/* Arrays */
			case TTuple( vals ):
				var values:Array<Value> = vals.map(toValue);
				return VArray( values );

			/* Field References */
			case TConst(CReference(name)):
				return VField( name );

			/* Anything Else */
			default:
				throw 'ValueError: Cannot get a Value from $t!';
		}
	}

	/**
	  * Create a Getter for the value of [val] is Haxe terms
	  */
	public static function haxeValue(val:Value, tools:CompilerTools, o:Dynamic):Getter<Dynamic> {
		switch ( val ) {
			case VString( str ):
				return Getter.create( str );

			case VNumber( num ):
				return Getter.create( num );

			case VArray( values ):
				return Getter.create([for (v in values) haxeValue(v, tools, o)]);

			case VField( name ):
				return Getter.create(tools.get(o, name));
		}
	}
}
