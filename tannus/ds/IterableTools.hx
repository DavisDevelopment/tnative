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

class IterableTools {
    public static function every<T>(list:Iterable<T>, pred:T->Bool):Bool {
        for (x in list)
            if (!pred( x ))
                return false;
        return true;
    }
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
	
    public static inline function reduce<T, TAcc>(a:Iterable<T>, f:TAcc->T->TAcc, v:TAcc):TAcc {
        for (x in a) {
            v = f(v, x);
        }
        return v;
    }
}
