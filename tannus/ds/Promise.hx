package tannus.ds;

import tannus.io.Signal;
import tannus.ds.Object;
import tannus.ds.EitherType;
import tannus.ds.promises.*;

import haxe.macro.Expr;
import haxe.macro.Context;

import tannus.internal.TypeTools.typename;
import Std.is;

using haxe.macro.ExprTools;
using haxe.macro.TypeTools;
using tannus.macro.MacroTools;

class Promise<T> {
	/* Constructor Function */
	public function new(exec:PromiseFunction<T>, ?nocall:Bool=false):Void {
		executor = exec;

		fulfillment = new Signal();
		rejection = new Signal();
		derived = new Array();

		if (!nocall)
			make();
	}

/* === Instance Methods === */

	/**
	  * Fulfill [this] Promise
	  */
	private function fulfill(v : T):Void {
		in_progress = false;
		fulfillment.call( v );
	}

	/**
	  * Reject [this] Promise
	  */
	private function reject(err : Dynamic):Void {
		in_progress = false;
		rejection.call( err );
	}

	/**
	  * Assert that [der] Promise is not 'made' until after [this] one
	  */
	private function derive<A>(der : Promise<A>):Void {
		derived.push( der );
	}

	/**
	  * Do something if [this] Promise is fulfilled
	  */
	public function then(callback : T->Void):Promise<T> {
		fulfillment.on( callback );
		return this;
	}

	/**
	  * Do something if [this] Promise is rejected
	  */
	public function unless(callback : Dynamic->Void):Promise<T> {
		rejection.on( callback );
		return this;
	}

	/**
	  * Do something if [this] Promise is EITHER fulfilled or rejected
	  */
	public function always(cb : Void->Void):Void {
		var called:Bool = false;
		then(function(x) if (!called) {
			cb();
			called = true;
		});
		unless(function(e) if (!called) {
			cb();
			called = true;
		});
	}

	/**
	  * 'Transform' [this] Promise
	  */
	public function transform<A>(change : T->A):Promise<A> {
		var res:Promise<A> = new Promise(function(res, err) {
			then(function(val) res(change(val)));
			unless(function(error) err(error));
		});
		attach( res );
		return res;
	}

	/**
	  * macro-licious [then]
	  */
	public macro function use(self:ExprOf<Promise<T>>, action:Expr) {
		action = action.mapUnderscoreTo('value');
		return macro {
			$self.then(function(value) {
				$action;
			});
		};
	}

	/**
	  * Obtain a reference to the Promise (if any) that spawned [this] one
	  */
	public function parent():Promise<Dynamic> {
		if (back != null) {
			return back;
		}
		else {
			throw 'PromiseError: Cannot read field \'back\' from the given Promise, as it has not yet been assigned';
		}
	}

	/**
	  * Attach [child] as being directly derived from [this] Promise
	  */
	public function attach<A>(child : Promise<A>):Promise<T> {
		derive( child );
		child.back = this;
		
		return this;
	}

	/**
	  * Get a reference to [this], but cast to type [t]
	  */
	public macro function as<A : Promise<Dynamic>>(self, t):ExprOf<A> {
		var me:String = self.toString();
		var tipe:String = t.toString();

		var code:String = '(cast($me, $tipe))';
		return Context.parse(code, Context.currentPos());
	}

	/**
	  * Get the data from [this] Promise
	  */
	public function make(?cb : Void->Void):Void {
		//- if no callback was provided, make one
		if (cb == null) {
			cb = (function() null);
		}

		//- if [this] Promise is not currently active
		if (!in_progress) {
			//- Mark [this] Promise as 'in progress'
			in_progress = true;

			//- 'make' all derived promises
			var stack = new AsyncStack();
			for (child in derived) {
				stack.push(function(nxt) {
					child.make( nxt );
				});
			}
			stack.run(function() {
				//- Attempt to fulfill [this] Promise
				var ff = function(x : T) {
					fulfill( x );
					cb();
				};
				var rj = function(e : Dynamic) {
					reject( e );
					cb();
				};
				executor(ff, rj);
			});
		}

		//- if [this] Promise is currently busy
		else {
			var remake = (function(max_calls : Int) {
				var run:Int = 0;

				function rm() {
					if (run < max_calls) {
						make();
						run++;
					}
				}

				return rm;
			}( 1 ));

			fulfillment.once(function(x) remake());
			rejection.once(function(x) remake());
		}
	}

	/**
	  * Output the results of [this] Promise once it has been fulfilled
	  */
	public inline function print():Promise<T> {
		then(function(x) trace(x));
		return this;
	}

	/**
	  * Create a TypeError message
	  */
	private inline function typeError(msg : String) return 'TypeError: $msg';

/* === Primitive Conversions === */

	/**
	  * Convert to a BoolPromise
	  */
	public function bool():BoolPromise {
		var res = new BoolPromise(function(yep, nope) {
			then(function(data : Dynamic) {
				if (Std.is(data, Bool)) {
					yep(cast data);
				}
				else {
					nope(typeError('Cannot cast $data to Boolean!'));
				}
			});

			unless( nope );
		});
		attach( res );
		return res;
	}

	/**
	  * Convert to a StringPromise
	  */
	public function string():StringPromise {
		var res:StringPromise = StringPromise.sp(yes, nope, {
			then(function(data : Dynamic) {
				if (is(data, String)) {
					yes(data + '');
				}
				else {
					nope(typeError('Cannot cast $data to String'));
				}
			});
		});
		attach( res );
		return res;
	}

	/**
	  * Convert to an ArrayPromise
	  */
	public function array<A>():ArrayPromise<A> {
		var res:ArrayPromise<A> = new ArrayPromise(function(yep, nope) {
			then(function(data : Dynamic) {
				try {
					#if js
					data = tannus.html.JSTools.arrayify( data );
					yep(cast data);
					#else
					var list:Array<A> = cast data;
					yep( list );
					#end
				}
				catch (error : Dynamic) {
					nope( error );
				}
				/*
				// trace(tannus.internal.TypeTools.typename( data ));
				if (is(data, Array<Dynamic>)) {
					try {
						var list:Array<A> = [for (x in cast(data, Array<Dynamic>)) cast x];
						yep( list );
					} 
					catch (err : String) {
						nope( err );
					}
				}
				else {
					nope(typeError('Cannot cast $data to Array!'));
				}
				*/
			});

			unless( nope );
		});
		attach( res );
		return res;
	}

	/**
	  * Convert to an ObjectPromise
	  */
	public function object():ObjectPromise {
		var res:ObjectPromise = (new ObjectPromise(function(reply, reject) {
			then(function(data : Dynamic) {
				var stype:String = typename(data);

				if (!is(data, Bool) && !is(data, Float) && !is(data, Array) && !is(data, String)) {
					switch (Type.typeof(data)) {
						case TObject, TClass(_):
							reply( data );

						default:
							reject(typeError('Cannot cast $stype to Object'));
					}
				}
				else {
					reject(typeError('Cannot cast $stype to Object'));
				}
			});
		}));
		attach( res );
		return res;
	}

/* === Operator Methods === */

	/**
	  * Test for equality between either a Promise and a value, or a Promise and another Promise
	  */
	public function eq(other : LogOpVal<T>):BoolPromise {
		return new BoolPromise(function(done, fail) {
			then(function(data : Dynamic) {
				other.switchType(val, prom, {
					done(val == data);
				}, {
					prom.then(function(val) done(val == data));
					prom.unless( fail );
				});
			});
			unless( fail );
		});
	}

/* === Promise Creation Methods === */

#if macro

	/**
	  * Convert from an apparently synchronous hunk of code, to an asynchronous, Promise-based equivalent
	  */
	public static function desynchronize(hunk:Expr, ?opts:Object):Expr {
		if (opts == null)
			opts = new Object({});

		var conf = {
			'fulfill_name' : (opts['fulfill'] || 'accept'),
			'fulf_macro_name' : (opts['fulfill-macro'] || 'return'),
			'reject_name' : (opts['reject'] || 'reject'),
			'rej_macro_name' : (opts['reject-macro'] || 'throw')
		};

		var fname:Expr = macro $v{conf.fulfill_name};
		var rname:Expr = macro $v{conf.reject_name};
		var macro_fname:Expr = macro $v{conf.fulf_macro_name};
		var macro_rname:Expr = macro $v{conf.rej_macro_name};

		function mapper(e : Expr) {
			switch (e.expr) {
				/* Convert 'return <result>' expressions into 'accept(<result>)' calls */
				case EReturn( res ):
					var result = res.map(mapper);
					return macro $fname( $res );

				/* convert 'throw <error>' statements into 'reject(<error>)' calls */
				case EThrow( err ):
					var error = err.map(mapper);
					return macro $rname( $error );

				/* Various meta-data magic */
				case EMeta(entry, expr):
					trace(expr.toString());
					switch (entry.name) {
						case (_ => _fn) if (entry.name == conf.fulfill_name):
							var desexpr = expr.map(mapper);
							return macro $fname( $desexpr );

						case (_ => _rn) if (entry.name == conf.reject_name):
							var desexpr = expr.map(mapper);
							return macro $rname( $desexpr );

						case 'ignore':
							return e;

						default:
							return e;
					}

				/* Anything Else */
				default:
					return e;
			}
		}
		
		return hunk.map( mapper );
	}

#end

	/**
	  * Parse a String into some Haxe expressions
	  */
	private static macro function parse(code : String) 
		return Context.parse(code, Context.currentPos());

	/**
	  * Map a synchronous snippet of code into a Promise-based asynchronous snippet
	  */
	public static macro function desync(block:Expr):Expr {
		return desynchronize( block );
	}

	/**
	  * Create standard Promise concisely
	  */
	public static macro function create<T>(action:Expr, ?nocall:ExprOf<Bool>):ExprOf<Promise<T>> {
		var yes = macro accept;
		var no = macro reject;

		function mapper(e : Expr) {
			switch (e.expr) {
				/* Return Statement */
				case EReturn( res ):
					var result = res.map(mapper);
					return macro accept($result);

				/* Throw Statement */
				case EThrow( err ):
					var error = err.map(mapper);
					return macro reject($error);

				/* Meta Statement */
				case ExprDef.EMeta(meta, ex):
					switch (meta.name) {
						case 'ignore':
							return ex;

						case 'promise':
							switch ( ex.expr ) {
								case ExprDef.ECall(efunc, args):
									var fi = efunc.funcInfo();
									if (fi != null) {
									    var rc = fi.ret.getRootClass();
									    if (rc != null) {
									        if (rc.fullName() == 'tannus.ds.Promise') {
									            return macro $ex.then($yes).unless($no);
									        }
									    }
									}
									args = args.concat([yes, no]);
									return {
										'expr': ECall(efunc, args),
										'pos': ex.pos
									};
								default:
									return ex;
							}

						case 'forward':
							return macro {
								$ex.then( accept ).unless( reject );
							};

						default:
							return e;
					}

				default:
					return e.map(mapper);
			}
		}

		action = action.map(mapper);

		if (nocall == null) {
			nocall = Context.makeExpr(false, Context.currentPos());
		}

		return macro new tannus.ds.Promise(function(accept, reject) {
			$action;
		}, $nocall);
	}

	/**
	  * Create Boolean Logical Operator BoolPromise
	  */
	public static macro function createLogOp<T>(op:String, left:ExprOf<Promise<T>>, right:Expr):ExprOf<BoolPromise> {
		var isPromise = (macro (Std.is($right, tannus.ds.Promise)));
		var comp = Context.parse('lval $op rval', Context.currentPos());

		return macro (new tannus.ds.Promise(function(accept, reject) {
			$left.then(function( lval ) {
				if ($isPromise) {
					var rp = cast($right, tannus.ds.Promise<Dynamic>);

					rp.then(function(rval)
						accept( $comp ));

					rp.unless( reject );
				}
				else {
					var rval = $right;
					accept( $comp );
				}
			});

			$left.unless(function(err) {
				reject( err );
			});
		}));
	}

#if js

    /**
      * Create a tannus Promise from a js Promise
      */
    public static function fromJsPromise<T>(jsp : js.Promise<T>):Promise<T> {
        return new Promise(function(accept, reject) {
            jsp.then(accept, reject);
        });
    }

    public inline function toJsPromise():js.Promise<T> {
        return new js.Promise(untyped executor);
    }

#end

/* === Instance Fields === */

	private var executor : PromiseFunction<T>;
	private var fulfillment : Signal<T>;
	private var rejection : Signal<Dynamic>;

	/* Whether [this] Promise is currently 'in progress', or made and unfulfilled */
	private var in_progress : Bool = false;
	private var derived : Array<Promise<Dynamic>>;
	private var back : Null<Promise<Dynamic>> = null;
}

typedef PromiseFunction<T> = Fullfill<T> -> Reject<T> -> Void;
typedef Fullfill<T> = T -> Void;
typedef Reject<T> = Dynamic -> Void;

/* Logical Operator Operand */
private typedef LogOpVal<T> = EitherType<T, Promise<T>>;
