package tannus.async;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Compiler;

using haxe.macro.ExprTools;
using haxe.macro.TypeTools;
using tannus.macro.MacroTools;
using haxe.macro.ComplexTypeTools;
using StringTools;
using tannus.ds.StringUtils;

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

								case 'promise':
									f.kind = FFun(promisifyFunction(f.name, func));
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
	  * Convert the given Function into a Function that returns a Promise
	  */
	private static function promisifyFunction(methodName:String, f:Function):Function {
		var rtype = f.ret;
		var ptype:ComplexType = (macro : tannus.ds.Promise<$rtype>);
		f.ret = ptype;
		f.expr = modBody( f.expr );
		var body:Expr = f.expr;
		var prome:Expr = macro tannus.ds.Promise.create( $body );
		var st:String = rtype.toString();
		if (st.startsWith( 'Array' )) {
			var atype:ComplexType = Context.getType(st.after('<').beforeLast('>')).toComplexType();
			f.ret = (macro : tannus.ds.promises.ArrayPromise<$atype>);
			prome = macro $prome.array();
		}
		else if (st == 'String') {
			f.ret = (macro : tannus.ds.promises.StringPromise);
			prome = macro $prome.string();
		}
		else if (st == 'Bool') {
			f.ret = (macro : tannus.ds.promises.BoolPromise);
			prome = macro $prome.bool();
		}
		f.expr = macro return $prome;
		return f;
	}

	/**
	  * Map the shit
	  */
	private static function asyncifyMapper(body:Expr, cbName:String):Expr {
		switch ( body.expr ) {
			case EMeta(s, retvalue) if (s.name == 'return'):
				return edef(ECall(macro $i{cbName}, [retvalue]));

			case EMeta(s, e) if (s.name == 'await_return'):
				switch ( e.expr ) {
					case ECall(fe, args):
						args.push(macro $i{cbName});
						return edef(ECall(fe, args));

					default:
						return macro throw 'Cock Butt';
				}

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
						/* @await [void async call] */
						case ECall(fe, args):
							var bod = list.slice(i + 1);
							var fargs:Array<FunctionArg> = new Array();
							if (s.params != null) {
								for (p in s.params) switch ( p.expr ) {
									case EConst(CIdent( name )):
										fargs.push({
											name: name,
											opt: null,
											type: null,
											value: null
										});
									default:
										continue;
								}
							}
							var awaitFunc:Expr = edef(EFunction(null, {
								ret : (macro : Void),
								params: null,
								expr: edef(EBlock(modList( bod ))),
								args : fargs
							}));
							
							/*
							var awetype = ctype( me );
							var promtype:ComplexType = (macro : tannus.ds.Promise<Dynamic>);
							if (awetype != null && (awetype.toType().unify(promtype.toType()))) {
								var unite = (awetype.toType().unify(promtype.toType()));
								var thenName = 'val';
								if (s.params != null) {
									switch (s.params[0].expr) {
										case EConst(CIdent(n)):
											thenName = n;
										default:null;
									} 
								}
								var thenFunc = edef(EFunction(null, {
									ret: macro : Void,
								    	params: null,
								    	expr: edef(EBlock(modList( bod ))),
								    	args: [{
										name: thenName,
								    		opt:null, type:null, value:null
								    	}]
								}));
								res.push(macro var promis = $me);
								var thencall:Expr = edef(ECall(macro promis.then, [thenFunc]));
								res.push( thencall );
								return res;
							}
							else {
							*/
								args.push( awaitFunc );
								res.push(edef(ECall(fe, args)));
								return res;
							//}

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

				/* == @trust Promise-based constructs == */
				case EMeta(s, me) if (s.name.startsWith( 'trust' )):
					switch ( me.expr ) {
						/* == standard call construct == */
						case ECall(fe, args):
							var after:Array<Expr> = list.slice(i + 1);
							var vardec:Expr = macro var promis = $me;
							var thenName:String = 'value';
							if (s.params != null) {
								switch (s.params[0].expr) {
									case EConst(CIdent( n )):
										thenName = n;
									default:
										null;
								}
							}
							var mod:BodyMod = modTrustBody(macro promis, after);
							var body:Expr = fromArray( mod.replace );
							var thenFunc = edef(EFunction(null, {
								ret : (macro : Void),
							    	params : null,
							    	expr : body,
							    	args : [{
									name : thenName,
							    		value:null, type:null, opt:null
							    	}]
							}));
							var thenCall = edef(ECall(macro promis.then, [thenFunc]));

							res.push( vardec );
							for (ee in mod.before)
								res.push( ee );
							res.push( thenCall );
							for (ee in mod.after)
								res.push( ee );
							return res;

						default:
							res.push( e );
					}

				/* == @async block == */
				case EMeta(s, me) if (s.name == 'async'):
					switch ( me.expr ) {
						case EBlock( list ):
							res.push(fromArray(modList( list )));

						default:
							res.push( e );
					}

				default:
					res.push( e );
			}
		}

		return res;
	}

	/* modify the given Array<Expr> */
	private static function modTrustBody(prom:Expr, list:Array<Expr>):BodyMod {
		var mod:BodyMod = {
			replace: new Array(),
			before: new Array(),
			after: new Array()
		};

		var first:Expr = list[0];
		switch ( first.expr ) {
			case ETry(tryBody, catches):
				var catchIfs:Array<Expr> = new Array();
				var dynamicCatch:Null<Catch> = null;
				var errName:String = '';
				
				var cas:tannus.ds.Stack<Catch> = new tannus.ds.Stack( catches );
				function nextIf():Null<Expr> {
					if ( cas.empty ) {
						return null;
					}
					else {
						var c = cas.pop();
						if (errName == '') {
							errName = c.name;
						}
						var err:Expr = edef(EConst(CIdent( errName )));
						var cond:Expr = edef(ECall(macro Std.is, [err, macro $i{c.type.toString()}]));
						c.expr = c.expr.replace(macro $i{errName}, err);
						var nxt = nextIf();
						var errif:Expr = edef(EIf(cond, c.expr, nxt));
						return errif;
					}
				}

				var ifChain:Expr = nextIf();

				tryBody = fromArray([tryBody].concat(list.slice( 1 )));
				mod.replace.push( tryBody );
				var unlessFunc = edef(EFunction(null, {
					ret : (macro : Void),
					params : null,
					expr : ifChain,
					args : [{
						name : errName,
						value:null, type: (macro : Dynamic), opt:null
					}]
				}));
				var unlessCall = edef(ECall(macro $prom.unless, [unlessFunc]));
				mod.after.push( unlessCall );

			default:
				for (e in list) {
					mod.replace.push( e );
				}
		}

		return mod;
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

	/* get the ComplexType of the given Expr */
	private static function ctype(e : Expr):Null<ComplexType> {
		try {
			return Context.typeof( e ).toComplexType();
		}
		catch (err : Dynamic) {
			return null;
		}
	}

	/**
	  * attempt to extract the Function type from the given Expr
	  */
	private static function getFunctionType(e : Expr):Null<FunctionType> {
		var type = ctype( e );
		if (type == null) {
			return null;
		}
		else {
			switch ( type ) {
				case TFunction(args, ret):
					return {args:args, ret:ret};

				default:
					return null;
			}
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
	private static function edef(e : ExprDef):Expr {
		return {pos:Context.currentPos(), expr:e};
	}
}

typedef FunctionType = {
	var args : Array<ComplexType>;
	var ret : ComplexType;
};

typedef BodyMod = {
	replace : Array<Expr>,
	before : Array<Expr>,
	after : Array<Expr>
};
