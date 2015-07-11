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

	/**
	  * Perform [action] on every item in the list
	  */
	public static macro function each<T>(list:ExprOf<Iterable<T>>, name, action) {
		return macro {
			for ($name in $list) {
				$action;
			}
		};
	}

	/**
	  * Check for [item] in [set], using a custom tester function
	  */
	public static function hasf<T>(set:Iterable<T>, item:T, tester:T->T->Bool):Bool {
		for (x in set)
			if (tester(x, item))
				return true;
		return false;
	}

	/**
	  * Obtain a copy of [set], with any/all duplicate items removed
	  */
	public static function unique<T>(set:Array<T>, ?tester:T->T->Bool):Array<T> {
		if (tester == null)
			tester = (function(x, y) return (x == y));

		var results:Array<T> = new Array();
		
		for (item in set) {
			if (!hasf(results, item, tester))
				results.push( item );
		}

		return results;
	}

	/**
	  * Flatten [set]
	  */
	public static function flatten<T>(set : Array<Array<T>>):Array<T> {
		var res:Array<T> = new Array();
		for (sub in set)
			res = res.concat( sub );
		return res;
	}
}
