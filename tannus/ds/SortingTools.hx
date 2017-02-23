package tannus.ds;

import tannus.math.TMath.*;

import Reflect.compare;

import Slambda.fn;

class SortingTools {
	/**
	  * chain together any number of sorters, which will be evaluated in order
	  */
	public static function chain(sorters : Array<Void -> Int>):Int {
		for (f in sorters) {
			var n = f();
			if (n == 0) {
				continue;
			}
			else {
				return n;
			}
		}
		return 0;
	}

	public static inline function stringComparator(x:String, y:String):Void->Int {
		return compare.bind(x, y);
	}
	public static inline function numComparator<T:Float>(x:T, y:T):Void->Int {
		return compare.bind(x, y);
	}
	public static inline function dateComparator(x:Date, y:Date):Void->Int {
		return numComparator(x.getTime(), y.getTime());
	}
	public static inline function comparator<T:IComparable<T>>(x:T, y:T):Void->Int {
		return x.compareTo.bind( y );
	}
}
