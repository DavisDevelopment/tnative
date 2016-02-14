package tannus.ds;

import tannus.io.Ptr;
import tannus.ds.tuples.Tup2;

import haxe.macro.Expr;
import haxe.macro.Context;

using haxe.macro.ExprTools;
using tannus.macro.MacroTools;

using Lambda;

class ArrayTools {
	/**
	  * Determine whether all items in the given Array are equal
	  */
	public static function equal<T>(a : Array<T>):Bool {
		for (i in 0...a.length) {
			for (j in i...a.length) {
				if (a[i] != a[j]) {
					return false;
				}
			}
		}
		return true;
	}

	/**
	  * macro-licious array equality
	  */
	public static macro function macequal<T>(a:ExprOf<Array<T>>, extractor:Expr):ExprOf<Bool> {
		var f:Expr = extractor.mapUnderscoreTo( 'item' );
		var rets = f.hasReturn();
		if ( rets ) 
			f = (macro function(item) $f);
		else
			f = (macro function(item) return $f);
		return (macro (function(list) {
			var f = $f;
			for (i in 0...list.length) {
				for (j in i...list.length) {
					if (f(list[i]) != f(list[j])) {
						return false;
					}
				}
			}
			return true;
		})( $a ));
	}

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
	  * Obtain a copy of [list] with all instances of [blacklist] removed */
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
	public static macro function each<T>(list:ExprOf<Iterable<T>>, action:Expr):Expr {
		action = action.mapUnderscoreTo( 'item' );
		return macro {
			for (item in $list) {
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
	  * obtain the intersection of two Arrays
	  */
	public static inline function intersection<T>(one:Array<T>, two:Array<T>):Array<T> {
		return ((one.length < two.length) ? macfilter(one, !two.has( _ )) : macfilter(two, !one.has( _ )));
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
		extractor = extractor.mapUnderscoreTo( 'item' );
		var hasret:Bool = extractor.hasReturn();
		var body:Expr = (hasret ? extractor : (macro return $extractor));
		return macro $set.map(function( item ) {
			$body;
		});
	}

	/**
	  * Macro-licious Array.filter
	  */
	public static macro function macfilter<T>(set:ExprOf<Array<T>>, test:Expr):ExprOf<Array<T>> {
		test = test.mapUnderscoreTo('item');
		test = (macro function(item) return $test);
		
		return (macro $set.filter( $test ));
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

	/**
	  * Get the item in the given list which scored the lowest, based on the given predicate
	  */
	public static function min<T>(list:Iterable<T>, predicate:T -> Float):T {
		var m:Null<Tup2<T, Float>> = null;
		for (x in list) {
			var score:Float = predicate( x );
			if (m == null || score < m._1) {
				m = new Tup2(x, score);
			}
		}
		if (m == null) {
			throw 'Error: Iterable must not be empty!';
		}
		return m._0;
	}

	/**
	  * Get the item in the given list which scored the highest, based on the given predicate
	  */
	public static function max<T>(list:Iterable<T>, predicate:T -> Float):T {
		var m:Null<Tup2<T, Float>> = null;
		for (x in list) {
			var score:Float = predicate( x );
			if (m == null || score > m._1) {
				m = new Tup2(x, score);
			}
		}
		if (m == null) {
			throw 'Error: Iterable must not be empty!';
		}
		return m._0;
	}

	/**
	  * Get the item in the given list which scored the lowest, based on the given predicate
	  */
	public static function minmax<T>(list:Iterable<T>, predicate:T -> Float):{min:T, max:T} {
		var l:Null<Tup2<T, Float>> = null;
		var h:Null<Tup2<T, Float>> = null;

		for (x in list) {
			var score:Float = predicate( x );
			
			if (l == null || score < l._1) {
				l = new Tup2(x, score);
			}

			else if (h == null || score > h._1) {
				h = new Tup2(x, score);
			}
		}
		if (l == null || h == null) {
			throw 'Error: Iterable must not be empty!';
		}
		
		return {
			'min': l._0,
			'max': h._0
		};
	}

	/**
	  * Perform a split-filter operation on the given Array, which splits an Array in to Arrays,
	  * one filled with those items that 'passed' the test, and the other
	  * filled with those who 'failed'
	  */
	public static function splitfilter<T>(list:Array<T>, pred:T->Bool):{pass:Array<T>, fail:Array<T>} {
		var res = {
			'pass': new Array(),
			'fail': new Array()
		};
		for (item in list) {
			(pred(item) ? res.pass : res.fail).push( item );
		}
		return res;
	}

	#if macro

	/**
	  * Map the shit
	  */
	public static function mapper(name:String, e:Expr):Expr {
		var mappr = mapper.bind(name, _);
		switch ( e.expr ) {
			/* == remap (_) to the given name == */
			case EConst(CIdent('_')):
				return parse( name );

			default:
				return e.map( mappr );
		}
	}

	/**
	  * convert a haxe code String into an Expression
	  */
	private static function parse(s : String):Expr {
		return Context.parse(s, Context.currentPos());
	}

	#end
}
