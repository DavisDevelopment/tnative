package tannus.ds;

import tannus.io.Ptr;

import haxe.macro.Expr;
import haxe.macro.Context;

using Lambda;
class ArrayTools {
	/**
	  * Obtain an Array of Pointers from an Array of values
	  */
	public static function pointerArray<T>(a : Array<T>):Array<Ptr<T>> {
		var res:Array<Ptr<T>> = new Array();
		for (i in 0...a.length) {
			res.push(Ptr.create(a[i]));
		}
		return res;
	}

	/**
	  * Obtain a copy of [list] with all instances of [blacklist] removed
	  */
	public static function without<T>(list:Array<T>, blacklist:Array<T>):Array<T> {
		var c = list.copy();
		for (v in blacklist) {
			while (true)
				if (!c.remove(v))
					break;
		}
		return c;
	}

	/**
	  * Obtain the first item in [list] Array which matches the given pattern
	  */
	public static macro function firstMatch<T>(list:ExprOf<Array<T>>, itemName, itemTest) {
		return macro (function() {
			var result:Dynamic = null;
			for ($itemName in $list) {
				var passed:Bool = ($itemTest);
				if (passed) {
					result = $itemName;
					break;
				}
			}
			return (cast result);
		}());
	}
}
