package tannus.async;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Compiler;

using haxe.macro.ExprTools;
using haxe.macro.TypeTools;
using tannus.macro.MacroTools;
using haxe.macro.ComplexTypeTools;

class AsyncBuilder {
	/**
	  * modify the fields of any class which implements Async
	  */
	public static macro function build():Array<Field> {
		var res:Array<Field> = new Array();
		var fields = Context.getBuildFields();

		for (f in fields) {
			switch ( f.kind ) {
				/* == Handle Class Methods == */
				case FFun( func ):
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

	/**
	  * Apply the @async mod to the given Function
	  */
	private static function asyncifyFunction(methodName:String, f:Function):Function {
		if (f.ret == null) {
			Context.fatalError('return type must be declared', Context.currentPos());
		}

		var ret:ComplexType = f.ret;
		var callbackType:ComplexType = (macro : $ret -> Void);
		f.args.push({
			'name': '${methodName}_cb',
			'type': callbackType,
			'opt': null,
			'value': null
		});
		f.ret = (macro : Void);
		f.expr = f.expr.map(asyncifyMapper.bind(_, '${methodName}_cb'));
		f.expr = modBody( f.expr );
		return f;
	}

	/**
	  * Map the shit
	  */
	private static function asyncifyMapper(body:Expr, cbName:String):Expr {
		switch ( body.expr ) {
			case EMeta(s, retvalue) if (s.name == 'return'):
				return edef(ECall(macro $i{cbName}, [retvalue]));

			default:
				return body.map(asyncifyMapper.bind(_, cbName));
		}
	}

	/**
	  * Apply global async modifications to the given Function
	  */
	private static function modFunc(f : Function):Function {
		f.expr = modBody( f.expr );
		return f;
	}

	/**
	  * Apply modifications to the given list of Expressions
	  */
	private static function modList(list : Array<Expr>):Array<Expr> {
		var res:Array<Expr> = new Array();

		for (i in 0...list.length) {
			var e = list[i];
			switch ( e.expr ) {
				/* == @await construct == */
				case EMeta(s, me) if (s.name == 'await'):
					switch ( me.expr ) {
						/* @await var [name] = [async call] */
						case EVars( vars ):
							var v = vars[0];
							var bod = list.slice(i + 1);
							switch ( v.expr.expr ) {
								case ECall(f, args):
									var awaitFunc:Expr = edef(EFunction(null, {
										ret : null,
										params: null,
										expr: edef(EBlock(modList( bod ))),
										args : [{
											name: v.name,
											opt:null,
											type:null,
											value:null
										}]
									}));
									args.push( awaitFunc );
									res.push(edef(ECall(f, args)));
									return res;

								default:
									res.push( e );
							}

						case EFor(iter, bod):
							var repl:Array<Expr> = new Array();
							repl.push(macro var stack = new tannus.ds.AsyncStack());
							bod = modBody( bod );
							bod = bod.replace(macro continue, macro next());
							repl.push(macro for ($iter) {
								stack.push(function( next ) $bod);
							});
							var after = edef(EBlock(modList(list.slice(i + 1))));
							repl.push(macro stack.run(function() $after));
							for (ee in repl) {
								res.push( ee );
							}
							return res;

						default:
							res.push( e );
					}

				default:
					res.push( e );
			}
		}

		return res;
	}

	/* convert the given Expression to an Array<Expr> and apply mods */
	private static function modBody(e : Expr):Expr {
		switch ( e.expr ) {
			case ExprDef.EBlock( list ):
				return edef(EBlock(modList( list )));
			default:
				return edef(EBlock(modList([e])));
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

	/* convert the given ExprDef into an Expr */
	private static function edef(e : ExprDef):Expr {
		return {pos:Context.currentPos(), expr:e};
	}
}
