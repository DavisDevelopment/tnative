package tannus.nore;

import tannus.io.Getter;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Expr.Binop;

using StringTools;
using Lambda;
using tannus.ds.StringUtils;
using tannus.ds.ArrayTools;

class ValueTools {
	/**
	  * Add an operator function for a base-operator
	  */
	public static macro function base(self:ExprOf<Compiler>, expr:Expr) {
		switch (expr.expr) {
			case EBinop(op, left, right):
				var e:Expr = {'expr': EBinop(op, (macro left), (macro right)), 'pos': Context.currentPos()};
				var opfunc = (macro function(left:Dynamic, right:Dynamic):Bool {
					return $e;
				});
				var opname:String = getOperatorName( op );
				return macro $self.operator($v{opname}, $opfunc);

			default:
				throw 'Error: Not a valid base-operator expression';
		}
	}

#if macro

	/**
	  * Get the textual representation of the given binary operator
	  */
	private static function getOperatorName(op : Binop):String {
		switch ( op ) {
			case OpEq:
				return '==';
			case OpNotEq:
				return '!=';
			case OpGt:
				return '>';
			case OpGte:
				return '>=';
			case OpLt:
				return '<';
			case OpLte:
				return '<=';
			default:
				return 'unknown';
		}
	}

#end

#if !macro
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
				var values:Array<Value> = vals.macmap(toValue(_));
				return VArray( values );

			/* Field References */
			case TConst(CReference(name)):
				return VField( name );

			/* Anything Else */
			default:
				throw 'ValueError: Cannot get a Value from $t!';
		}
	}
#end

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
