package tannus.io;

import haxe.macro.Expr;
import haxe.macro.Context;

using StringTools;
using Lambda;
using haxe.macro.ExprTools;

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
}
