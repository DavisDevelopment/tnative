package tannus.ds;

import tannus.io.Ptr;
import tannus.ds.tuples.Tup2;
import tannus.ds.dict.DictKey;

import haxe.macro.Expr;
import haxe.macro.Context;

using haxe.macro.ExprTools;
using tannus.macro.MacroTools;

using Lambda;
using tannus.ds.FunctionTools;
using tannus.FunctionTools;

// @:expose( 'ArrayTools' )
class ArrayTools {
	/**
	  * macro-magic for extracting values from an Array
	  */
	public static macro function with<T>(a:ExprOf<Array<T>>, enames:Expr, action:Expr) {
		var names:Array<Expr> = new Array();
		switch ( enames.expr ) {
			case EArrayDecl( list ):
				names = list;

			default:
				Context.error('Error: Invalid argument for ArrayTools.with', Context.currentPos());
		}

		for (index in 0...names.length) {
			var ename:Expr = (macro $a[$v{ index }]);
			action = action.replace(names[index], ename);
		}

		return action;
	}

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
	  * compare two Arrays
	  */
	public static function compare<T>(left:Array<T>, right:Array<T>, ?predicate:T -> T -> Bool):Bool {
		/* if the two arrays are not of the same size */
		if (left.length != right.length) {
			/* they cannot be equal */
			return false;
		}
		/* if the two arrays are the same size */
		else {
			/* if [predicate] was not provided */
			if (predicate == null) {
				/* use the default */
				predicate = (function(x, y) return (x == y));
			}

			/* for every index in the two arrays */
			for (i in 0...left.length) {
				/* get item in [left] at the current index */
				var l = left[ i ];
				/* get the item in [right] at the current index */
				var r = right[ i ];
				/* if [predicate] returns false */
				if (!predicate(l, r)) {
					/* then the two arrays are not equal */
					return false;
				}
			}

			/* 
			   If the function makes it this far, then either the arrays were both empty, 
			   or [predicate] returned 'true' for all values. In either case, the two arrays
			   can be said to be equivalent
			 */
			return true;
		}
	}

	/**
	  * macro-licious 'compare'
	  */
	public static macro function maccompare<T>(left:ExprOf<Array<T>>, right:ExprOf<Array<T>>, args:Array<Expr>):ExprOf<Bool> {
		var predicate:Null<Expr> = args[0];
		if (predicate == null) {
			predicate = (macro null);
		}
		else {
			var le:Array<Expr> = [macro x];
			var re:Array<Expr> = [macro y];
			
			/* if a fourth and fifth argument are provided, use them as the expressions for [x] and [y] */
			if (args[1] != null && args[2] != null) {
				le.push(args[1]);
				re.push(args[2]);
			}

			/* map all instances of [le] and [re] to 'left' and 'right' respectively */
			predicate = predicate.replaceMultiple(le, macro left);
			predicate = predicate.replaceMultiple(re, macro right);

			/* add a 'return' expression to [predicate], if one is not already present */
			if (!predicate.hasReturn()) {
				predicate = (macro return $predicate);
			}

			/* wrap [predicate] in a function definition */
			predicate = (macro function(left, right) $predicate);
		}

		return macro tannus.ds.ArrayTools.compare($left, $right, $predicate);
	}

    /**
      * remove all null items from [a]
      */
	public static function compact<T>(a:Array<Null<T>>):Array<T> {
	    return a.filter(i -> (null != i));
	}

    /**
      * check if [a] is either a null value, or an Array without any values
      */
	public static inline function empty<T>(a: Array<T>):Bool {
	    return (null == a || a.length == 0);
	}

    /**
      * check that [a] is not null, has more than one value, and that it doesn't contain only null values
      */
	public static inline function hasContent<T>(a: Null<Array<T>>):Bool {
	    return !(empty( a ) || (empty(compact( a ))));
	}

	/**
	  * normalize any Array for which [hasContent] would return false to null
	  */
	public static inline function nullEmpty<T>(a: Null<Array<T>>):Null<Array<T>> {
	    return (hasContent( a ) ? a : null);
	}

    /**
      * picks from two arrays based on the given [check] function
      */
	public static function or<T>(a:Array<T>, b:Array<T>, ?test:Array<T>->Bool):Array<T> {
	    if (test != null) {
	        return (if (test( a )) a else b);
	    }
        else {
            if (empty( a )) {
                return b;
            }
            return a;
        }
	}

    /**
      * 
      */
	public static inline function notEmpty<T>(a:Array<T>, defaultVal:Array<T>, hasContent:Bool=false):Array<T> {
	    if ((hasContent && !ArrayTools.hasContent( a )) || empty( a )) {
	        return defaultVal;
	    }
        return a;
	}

    /**
      *
      */
    public static function rotate<T>(a : Array<Array<T>>) : Array<Array<T>> {
        var result:Array<Array<T>> = [];
        for(i in 0...a[0].length) {
            var row:Array<T> = [];
            result.push( row );
            for(j in 0...a.length) {
                row.push(a[j][i]);
            }
        }
        return result;
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
	public static function without<T>(list:Iterable<T>, blacklist:Iterable<T>, ?compare:T->T->Bool):Array<T> {
		if (compare == null) {
			compare = (function(x,y) return (x == y));
		}
		var result:Array<T> = new Array();
		for (x in list) {
			for (y in blacklist) {
				if (compare(x, y)) {
					continue;
				}
			}
			result.push( x );
		}
		return result;
	}

	/**
	  * Obtain the differences between two arrays
	  */
	/*
	public static function difference<T>(a:Array<T>, b:Array<T>, eq:T->T->Bool):ArrayDelta<T> {
		eq = eq.memoize();
		var delta = {
			add: [],
			//move: [],
			remove: []
		};

		var remove = a.without(b, eq);
		var _add = b.without(a, eq);
		var add = new Array();
		for (x in _add) {
			var i = b.indexOf( x );
			add.push({item:x, index:i});
		}
		return {
			add: add,
			remove: remove
		};
	}

	/**
	  * Obtain the first item in [list] Array which matches the given pattern
	  */
	public static function firstMatch<T>(list:Iterable<T>, test:T->Bool):Null<T> {
		for (item in list) {
			if (test( item )) {
				return item;
			}
		}
		return null;
	}

	/**
	  * Obtain the index of the first item in [list] Array which matches the given pattern
	  */
	public static function firstMatchIndex<T>(list:Array<T>, test:T->Bool):Int {
		for (index in 0...list.length) {
			if (test(list[index])) {
				return index;
			}
		}
		return -1;
	}

	/**
	  * macro-licious firstMatch
	  */
	public static macro function macfirstMatch<T>(list:ExprOf<Iterable<T>>, test:Expr):ExprOf<Null<T>> {
		test = test.mapUnderscoreTo( 'item' );
		if (!test.hasReturn()) {
			test = macro return $test;
		}
		test = macro (function(item) $test);
		return macro tannus.ds.ArrayTools.firstMatch($list, $test);
	}

	/**
	  * macro-licious firstMatchIndex
	  */
	public static macro function macfirstMatchIndex<T>(list:ExprOf<Array<T>>, test:Expr):ExprOf<Int> {
		test = test.mapUnderscoreTo( 'item' );
		if (!test.hasReturn()) {
			test = macro return $test;
		}
		test = macro (function(item) $test);
		return macro tannus.ds.ArrayTools.firstMatchIndex($list, $test);
	}

	/**
	  * Perform [action] on every item in the list
	  */
	public static macro function each<T>(list:ExprOf<Iterable<T>>, action:Expr):Expr {
		action = action.replace(macro _, macro item);

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
	public static function min<T>(list:Iterable<T>, predicate:T -> Float):Null<T> {
		var m:Null<Tup2<T, Float>> = null;
		for (x in list) {
			var score:Float = predicate( x );
			if (m == null || score < m._1) {
				m = new Tup2(x, score);
			}
		}
		if (m == null) {
			//throw 'Error: Iterable must not be empty!';
			return null;
		}
		return m._0;
	}

	/**
	  * Get the item in the given list which scored the highest, based on the given predicate
	  */
	public static function max<T>(list:Iterable<T>, predicate:T -> Float):Null<T> {
		var m:Null<Tup2<T, Float>> = null;
		for (x in list) {
			var score:Float = predicate( x );
			if (m == null || score > m._1) {
				m = new Tup2(x, score);
			}
		}
		if (m == null) {
			//throw 'Error: Iterable must not be empty!';
			return null;
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
	public static function splitfilter<T>(list:Array<T>, pred:T->Bool):SplitFilterResult<T> {
		var res = {
			'pass': new Array(),
			'fail': new Array()
		};
		for (item in list) {
			(pred(item) ? res.pass : res.fail).push( item );
		}
		return res;
	}

	/**
	  * macro-licious split-filter
	  */
	public static macro function macsplitfilter<T>(list:ExprOf<Array<T>>, test:Expr):ExprOf<SplitFilterResult<T>> {
		test = test.mapUnderscoreTo( 'item' );
		if (!test.hasReturn()) {
			test = macro return $test;
		}
		test = macro (function(item) $test);
		return macro tannus.ds.ArrayTools.splitfilter($list, $test);
	}

	/**
	  * partition the given Array
	  */
	public static function partition<T>(list:Array<T>, pred:T->Bool):Array<Array<T>> {
		var results:Array<Array<T>> = [[], []];
		for (x in list) results[pred(x) ? 0 : 1].push( x );
		return results;
	}

	public static macro function macpartition<T>(list:ExprOf<Array<T>>, pred:Expr):ExprOf<Array<Array<T>>> {
		pred = pred.replace(macro _, macro x).buildFunction(['x']);
		return macro tannus.ds.ArrayTools.partition($list, $pred);
	}

	/**
	  * filter and map simultaneously
	  */
	public static function mapfilter<A, B>(list:Array<A>, test:A->Bool, map:A->B):Array<B> {
		var results:Array<B> = new Array();
		for (x in list) {
			if (test( x )) {
				results.push(map( x ));
			}
		}
		return results;
	}

	/**
	  * macro-licious mapfilter
	  */
	public static macro function macmapfilter<A, B>(list:ExprOf<Array<A>>, test:Expr, map:Expr):ExprOf<Array<B>> {
		test = test.replace(macro _, macro item);
		map = map.replace(macro _, macro item);
		if (!test.hasReturn()) test = macro return $test;
		if (!map.hasReturn()) map = macro return $map;
		test = macro (function(item) $test);
		map = macro (function(item) $map);

		return macro tannus.ds.ArrayTools.mapfilter($list, $test, $map);
	}

	/**
	  * convert a pair of Arrays into an Array of pairs
	  */
	public static function zip<A, B>(left:Array<A>, right:Array<B>):Array<Pair<A, B>> {
		var pairs:Array<Pair<A, B>> = new Array();
		for (i in 0...left.length) {
			pairs.push(new Pair(left[i], right[i]));
		}
		return pairs;
	}

	/**
	  * macro-based zip-map
	  */
	public static function zipmap<A, B, C>(left:Array<A>, right:Array<B>, predicate:A->B->C):Array<C> {
		var pairs = zip(left, right);
		return [for (p in pairs) predicate(p.left, p.right)];
	}

	/**
	  * macro-based zip-map
	  */
	public static macro function maczipmap<A, B, C>(left:ExprOf<Array<A>>, right:ExprOf<Array<B>>, args:Array<Expr>):ExprOf<Array<C>> {
		var lExpressions:Array<Expr> = [macro x];
		var rExpressions:Array<Expr> = [macro y];
		var f:Expr = args[0];

		switch ( args ) {
			case [leftExpr, rightExpr, action]:
				lExpressions.push( leftExpr );
				rExpressions.push( rightExpr );
				f = action;

			case [action]:
				f = action;

			default:
				null;
		}

		// map all given [left] and [right] aliases to just 'left' and 'right' respectively
		f = f.replaceMultiple(lExpressions, macro left).replaceMultiple(rExpressions, macro right);
		
		/* if [f] does not contain a 'return' statement */
		if (!f.hasReturn()) {
			/* automagically return the last expression (usually the only one) */
			var body:Array<Expr> = f.toArray();
			var rve:Expr = body.pop();
			body.push(macro return $rve);
			f = body.fromArray();
		}

		/* wrap [f] in a function definition, making [f] now the body of said function */
		f = (macro function(left, right) $f);
		//trace(f.toString());

		return macro tannus.ds.ArrayTools.zipmap($left, $right, $f);
	}

	/**
	  * macro-licious sort
	  */
	public static macro function macsort<T>(list:ExprOf<Array<T>>, parameters:Array<Expr>):Expr {
		var leftExpr:Array<Expr> = [macro x];
		var rightExpr:Array<Expr> = [macro y];
		var func:Expr = macro 0;

		switch ( parameters ) {
			case [left, right, action]:
				leftExpr.push( left );
				rightExpr.push( right );
				func = action;

			case [action]:
				func = action;

			default:
				null;
		}

		func = func.replaceMultiple(leftExpr, macro left).replaceMultiple(rightExpr, macro right);
		func = func.buildFunction(['left', 'right']);
		return macro haxe.ds.ArraySort.sort($list, $func);
	}

	/**
	  * Build a Dict from a zipped Array
	  */
	//@:generic
	//public static function dict<K : DictKey>(pairs : Array<Pair<K, Dynamic>>):Dict<K, Dynamic> {
		//var d = new Dict();
		//for (p in pairs) d.set(p.left, p.right);
		//return d;
	//}

	/**
	  * build a Grid<T> from an Array<Array<T>>
	  */
	public static inline function gridify<T>(arr : Array<Array<T>>):Grid<T> {
		return tannus.ds.Grid.fromArray2( arr );
	}

	/**
	  * (if necessary) enlarge [list] to [len] by prepending [value]
	  * to [list] until it's of the desired length
	  */
	public static function lpad<T>(list:Array<T>, len:Int, value:T):Array<T> {
		if (list.length >= len) {
			return list;
		}
		else {
			var res = list.copy();
			while (res.length < len) res.unshift( value );
			return res;
		}
	}

	/**
	  * (if necessary) enlarge [list] to [len] by appending [value]
	  * to [list] until it's of the desired length
	  */
	public static function rpad<T>(list:Array<T>, len:Int, value:T):Array<T> {
		if (list.length >= len) {
			return list;
		}
		else {
			var res = list.copy();
			while (res.length < len) res.push( value );
			return res;
		}
	}

	/**
	  * check that [test] returns 'true' for every item in [list]
	  */
	public static function every<T>(list:Iterable<T>, test:T->Bool):Bool {
		for (x in list) {
			if (!test( x )) {
				return false;
			}
		}
		return true;
	}

	public static macro function macevery<T>(list:ExprOf<Iterable<T>>, test:Expr):ExprOf<Bool> {
		test = test.replace(macro _, macro x);
		test = test.buildFunction(['x']);
		return macro tannus.ds.ArrayTools.every($list, $test);
	}

	/**
	  * break the given Array into chunks of [size] length
	  */
	public static function chunk<T>(array:Array<T>, size:Int):Array<Array<T>> {
		var chunks = [], ch = [];
		for (x in array) {
		    ch.push( x );
		    if (ch.length == size) {
		        chunks.push( ch );
		        ch = [];
		    }
		}
		return chunks;
	}

	/**
	  * iterate over the given Array and apply [keygen] to each item
	  * the value returned by [keygen] is the key under which an Array is stored,
	  * and every 'item' for which [keygen] returns that same key is appended to 
	  * said Array
	  */
	//@:generic
	//public static function group<K, V>(list:Iterable<V>, keygen:V->K):Dict<K, Array<V>> {
		//var d = new Dict();
		//for (item in list) {
			//var key:K = keygen( item );
			//if (!d.exists( key )) {
				//d.set(key, new Array());
			//}
			//d.get( key ).push( item );
		//}
		//return d;
	//}

	/**
	  * iterate over [list], and apply [keygen] to each item
	  * the value returned by [keygen] becomes the key under which the 
	  * value returned by applying [mapper] to the item is stored
	  */
	//@:generic
	//public static inline function index<K, V:Dynamic>(list:Iterable<V>, keygen:V -> K):Dict<K, V> {
		//var d = new Dict();
		//for (item in list) {
			//d.set(keygen(item), item);
		//}
		//return d;
	//}

	/**
	  * macro-licious 'group'
	  */
	//public static macro function macgroup<K,V>(list:ExprOf<Iterable<V>>, key:Expr):ExprOf<Dict<K, Array<V>>> {
		//var keygen:Expr;
		//key = key.replace(macro _, macro item);
		//keygen = key.buildFunction(['item']);

		//return macro tannus.ds.ArrayTools.group($list, $keygen);
	//}

	/**
	  * macro-licious 'group'
	  */
	//public static macro function macindex<K, V>(list:ExprOf<Iterable<V>>, key:Expr):ExprOf<Dict<K, V>> {
		//var keygen:Expr;
		//key = key.replace(macro _, macro item);
		//keygen = key.buildFunction(['item']);

		//return macro tannus.ds.ArrayTools.index($list, $keygen);
	//}

	/**
	  * Check whether [test] returned true for any of the given items
	  */
	public static function any<T>(items:Iterable<T>, test:T->Bool):Bool {
		for (item in items) {
			if (test( item )) {
				return true;
			}
		}
		return false;
	}

	public static function all<T>(items:Iterable<T>, test:T->Bool):Bool {
	    return !any(items, test.negate());
	}

    public static function reduce<T, TAcc>(a:Iterable<T>, f:TAcc->T->TAcc, v:TAcc):TAcc {
        for (x in a) {
            v = f(v, x);
        }
        return v;
    }

    public static function reducei<T,TAcc>(a:Array<T>, f:TAcc->T->Int->TAcc, v:TAcc):TAcc {
        for (i in 0...a.length)
            v = f(v, a[i], i);
        return v;
    }

    public static inline function reduceRight<T,TAcc>(a:Array<T>, f:TAcc->T->TAcc, v:TAcc):TAcc {
        var i:Int = a.length;
        while (--i >= 0)
            v = f(v, a[i]);
        return v;
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

typedef SplitFilterResult<T> = {pass:Array<T>, fail:Array<T>};
typedef ArrayDelta<T> = {
	add: Array<T>,
	remove: Array<T>,
	move: Array<{item:T, index:Int}>
};

private typedef Measurable = {
	var length : Int;
};
