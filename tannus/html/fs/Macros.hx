package tannus.html.fs;

import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.ExprTools;
using tannus.macro.MacroTools;

class Macros {
	public static macro function withentry(fp:ExprOf<FilePromise>, action:Expr) {
		action = action.mapUnderscoreTo( 'entry' );
		action = macro (function(entry) $action);
		return macro {
			$fp.useEntry( $action );
		};
	}
}
