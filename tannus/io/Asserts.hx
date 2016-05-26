package tannus.io;

import haxe.macro.Expr;
import haxe.macro.Context;

using StringTools;
using Lambda;
using haxe.macro.ExprTools;
using tannus.macro.MacroTools;

class Asserts {
	/**
	  * Verify that [condition] evaluates to 'true', and if it doesn't, throw [error]
	  */
	public static macro function assert(condition:ExprOf<Bool>, error:Expr) {
		return macro {
			if ($condition) {
				null;
			}
			else {
				throw $error;
			}
		};
	}

	/**
	  * Verify that the given expression is of the given Type
	  */
	public static macro function assertType(value:Expr, _type:Expr) {
		var isType:Expr = macro Std.is($value, $_type);
		var etn:String = _type.toString();
		var tn:Expr = macro tannus.internal.TypeTools.typename($value);
		return macro {
			if (!($isType)) {
				throw ('TypeError: Expected ' + $v{etn} + ' but got ' + $tn + '!');
			}
		};
	}

	/**
	  * verify that the given value is non-null
	  */
	public static macro function nn<T>(value:ExprOf<T>, action:Expr) {
		action = action.mapUnderscoreTo(value.toString());
		return macro if ($value != null) {
			$action;
		};
	}
}
