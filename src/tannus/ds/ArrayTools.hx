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
	  * Obtain the union of two Arrays
	  */
	public static function union<T>(one:Array<T>, other:Array<T>):Array<T> {
		return one.filter(function(item) {
			return other.has( item );
		});
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

	/**
	  * Macro-Licious Array.map
	  */
	public static macro function macmap<T, O>(set:ExprOf<Array<T>>, extractor:ExprOf<O>):ExprOf<Array<O>> {
		return macro $set.map(function( item ) {
			return $extractor;
		});
	}

	/**
	  * Get the last item in the given Array
	  */
	public static function last<T>(list:Array<T>, ?v:T):T {
		if (v == null) {
			return (list[list.length - 1]);
		}
		else {
			return (list[list.length - 1] = v);
		}
	}

	/**
	  * Get all the items in the given Array that occur before the given value
	  */
	public static inline function before<T>(list:Array<T>, val:T):Array<T> {
		return (list.slice(0, (list.indexOf(val) != -1 ? list.indexOf(val) : list.length)));
	}

	/**
	  * Get all the items in the given Array that occur after the given value
	  */
	public static inline function after<T>(list:Array<T>, val:T):Array<T> {
		return (list.slice((list.indexOf(val)!=-1 ? list.indexOf(val) + 1 : 0)));
	}

	/**
	  * Repeat the given array the given number of times
	  */
	public static function times<T>(list:Array<T>, n:Int):Array<T> {
		var res = list.copy();
		for (i in 0...n-1) {
			res = res.concat(list.copy());
		}
		return res;
	}
}
