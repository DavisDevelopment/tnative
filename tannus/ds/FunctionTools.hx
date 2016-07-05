package tannus.ds;

import haxe.Constraints.Function;

import Std.*;

import haxe.macro.Expr;
import haxe.macro.Context;

using Type;
using Reflect;
using haxe.macro.ExprTools;
using tannus.macro.MacroTools;

class FunctionTools {
	/* memoize */
	public static macro function macmemoize<T>(f:ExprOf<T>, args:Array<Expr>):ExprOf<T> {
		var str:Expr = macro null;
		if (args.length > 0) {
			str = args[0].replace(macro _, macro x).buildFunction(['x:Dynamic']);
		}
		return macro tannus.ds.FunctionTools.memoize($f.bind(), $str);
	}

	/**
	  * Memoizes the given Function 
	  */
	public static function memoize<T>(f:T, ?str:Dynamic->String):T {
		if (str == null) {
			str = string;
		}

		var cache:Map<String, Dynamic> = new Map();

		return untyped (function(args : Array<Dynamic>):Dynamic {
			var key = str( args );
			if (cache.exists( key  )) {
				return cache.get( key  );
			}
			else {
				var result:Dynamic = Reflect.callMethod(null, (untyped f), args);
				cache.set(key, result);
				return result;
			}
		}).makeVarArgs();
	}
}
