package tannus.ds;

import tannus.macro.MacroTools;
import tannus.io.*;

import Slambda.fn;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using Lambda;
using Slambda;
using tannus.macro.MacroTools;
using haxe.macro.ExprTools;
using haxe.macro.TypeTools;

class AnonTools {
    /**
      * more generic and commonly useful 'owith'
      */
    public static macro function with(o:Expr, action:Expr) {
        var ers:Array<Expr> = new Array();
        switch ( action.expr ) {
            case EBinop(OpArrow, {pos:_,expr:EArrayDecl(names)}, body):
                action = body;
                ers = names;

            case EBinop(OpArrow, name, body):
                action = body;
                ers[0] = name;

            default:
                null;
        }

        switch ( o.expr ) {
            case EArrayDecl( values ):
                for (index in 0...values.length) {
                    var e = values[index];
                    if (ers[index] != null)
                        action = action.replace(ers[index], e);
                    else {
                        var er:Expr = (macro $i{'_' + (index + 1)});
                        action = action.replace(er, e);
                    }
                }

            default:
                if (ers[0] != null)
                    action = action.replace(ers[0], o);
                else
                    action = action.replace(macro _, o);
        }

        return action;
    }

	/**
	  * 'with'
	  */
	public static macro function owith<T>(o:ExprOf<T>, action:Expr) {
		var type = Context.typeof( o ).getClass();
		var map:Map<String, ClassField> = new Map();
		var list = type.fields.get();
		for (f in list) {
			map[f.name] = f;
		}
		var out:Expr = action;
		for (name in map.keys()) {
			var ident:Expr = macro $i{name};
			var field:Expr = {
				pos: Context.currentPos(),
				expr: ExprDef.EField(o, name)
			};
			out = withReplace(out, ident, field);
		}
		return out;
	}

#if macro

	private static function withReplace(e:Expr, x:Expr, y:Expr):Expr {
		if (e.expr.equals( x.expr )) {
			return y;
		}
		else {
			return e.map(wrMapper.bind(_, x, y));
		}
	}

	private static function wrMapper(e:Expr, x:Expr, y:Expr):Expr {
		switch ( e.expr ) {
			case EMeta(s, ee) if (s.name == 'ignore'):
				return ee;
			default:
				if (e.expr.equals( x.expr )) {
					return y;
				}
				else {
					return e.map(wrMapper.bind(_, x, y));
				}
		}
	}

#end
}
