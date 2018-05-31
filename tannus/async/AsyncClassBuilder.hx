package tannus.async;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Compiler;

using haxe.macro.ExprTools;
using haxe.macro.TypeTools;
using tannus.macro.MacroTools;
using haxe.macro.ComplexTypeTools;
using haxe.macro.PositionTools;
using StringTools;
using tannus.ds.StringUtils;
using tannus.ds.ArrayTools;

class AsyncClassBuilder {
    static var currentPos: Position;

    public static macro function build():Array<Field> {
		var res:Array<Field> = new Array();
		var fields = Context.getBuildFields();

		for (f in fields) {
			switch ( f.kind ) {
				/* == Handle Class Methods == */
				case FFun( func ):
				    currentPos = f.pos;

					/* if the method has metadata */
					if (f.meta != null) {
						var handled:Bool = false;
						for (m in f.meta) {
							/* handle the metadata */
							switch ( m.name ) {
								/* == @async construct == */
								case 'async':
									f.kind = FFun(asyncifyFunction(f.name, func));
									handled = true;

								default:
									continue;
							}
						}
						if ( !handled ) {
							f.kind = FFun(modFunc( func ));
						}
					}
					else {
						f.kind = FFun(modFunc( func ));
					}

				default:
					null;
			}

			res.push( f );
		}

		return res;
    }

    static function asyncifyFunction(f: Function):Function {
        var ret:ComplexType = f.ret;
        f.ret = (macro : tannus.async.Promise<$ret>);
        //
    }

    static function modList(list:Array<Expr>, ?pos:Position):Array<Expr> {
        if (pos == null)
            pos = Context.currentPos();

        var modded:Array<Expr> = new Array();
        var e:Expr;
        for (i in 0...list.length) {
            e = list[e];
            switch e {
                case macro var $evar:$etype = @await $promExpr:
                    //etype.asGetter(
                    var prom:Expr = macro $promExpr;
                    var body:Expr = edef(EBlock(modList(list.slice(i + 1), promExpr.pos)), promExpr.pos);
                    var promThen:Expr = (macro function($evar: $etype) {
                        $body;
                    });
                    var res:Expr = macro $prom.then($promThen);
                    return res;

                case macro $evalue = @await $promExpr:
                    var body:Expr = edef(EBlock(modList(list.slice(i + 1), promExpr.pos)), promExpr.pos);
            }
        }
    }

    static function getFunction(e: Expr):Null<FuncInfo> {
        switch e.expr {
            case EFunction(name, func):
                var info:FuncInfo = {f: func};
                if (name != null) {
                    info.name = name;
                }
                return info;

            case _:
                return null;
        }
    }

	/**
	  * Apply global async modifications to the given Function
	  */
	private static function modFunc(f : Function):Function {
		f.expr = modBody( f.expr );
		return f;
	}

    static function modBody(e: Expr):Expr {
        switch e.expr {
            case EBlock(list):
                return edef(EBlock(modList(list, e.pos)), e.pos);

            case _:
                return edef(EBlock(modList([e], e.pos)), e.pos);
        }
    }

	/* convert the given Expr to an Array<Expr> */
	private static function toArray(e : Expr):Array<Expr> {
		switch ( e.expr ) {
			case EBlock( list ):
				return list;

			default:
				return [e];
		}
	}

	private static function fromArray(list : Array<Expr>):Expr {
		return edef(EBlock( list ));
	}

    /* convert the given ExprDef into an Expr */
	private static function edef(e:ExprDef, ?pos:Position):Expr {
	    if (pos == null)
	        pos = Context.currentPos();
		return {
		    pos: pos,
		    expr: e
		};
	}
}

typedef FuncInfo = {
    ?name: String,
    f: Function
}
