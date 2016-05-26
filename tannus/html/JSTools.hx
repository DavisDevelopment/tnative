package tannus.html;

import tannus.ds.Obj;

import haxe.macro.Expr;
import haxe.macro.Context;

using haxe.macro.ExprTools;
using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;

class JSTools {
	/**
	  * Convert the given object into an Array
	  */
	public static inline function arrayify<T>(o : Dynamic):Array<T> {
		return cast (untyped __js__('Array.prototype.slice.call')(o, 0));
	}

/* === Private Shit === */
}
