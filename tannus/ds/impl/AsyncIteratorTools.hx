package tannus.ds.impl;

import tannus.io.Input;
import tannus.io.Signal;
import tannus.io.Input.Err;
import tannus.io.Signal;
import tannus.io.VoidSignal;

import tannus.ds.impl.AsyncIterationDataSource in Aids;
import tannus.ds.impl.AsyncIterationContext in Ctx;
import tannus.ds.impl.AsyncIterToken;
import tannus.ds.impl.FunctionalAsyncDataSource.SourceFunction in FDSourceFunction;
import tannus.ds.impl.FunctionalAsyncIterationContext.FAICSpec;
import tannus.ds.impl.*;

import haxe.macro.Context;
import haxe.macro.Expr;

using Lambda;
using tannus.ds.ArrayTools;
using StringTools;
using tannus.ds.StringUtils;
using tannus.macro.MacroTools;
using haxe.macro.ExprTools;

class AsyncIteratorTools {
#if macro
	
	public static function buildGeneratorFunction<T>(body : Expr):ExprOf<FDSourceFunction<T>> {
		body = compileGeneratorSyntax( body );
		
		var genfunc:Expr = (macro function(ds) {
			$body;
		});

		return genfunc;
	}

	/**
	  * method to transform/compile generator syntax into standard Haxe code
	  */
	public static function compileGeneratorSyntax(body : Expr):Expr {
		var src:Expr = (macro ds);

		var output:Expr = body.map(cgs_mapper.bind(_, src));

		return output;
	}

	/**
	  * expression-mapping method used to transform the generator syntax into valid Haxe code
	  */
	private static function cgs_mapper(e:Expr, src:Expr):Expr {
		var pos:Position = e.pos;
		
		switch ( e.expr ) {
			case EMeta(m, valueExpr) if (m.name == 'yield'):
				return macro ($src.next( $valueExpr ));

			case EBreak:
				return macro ($src.end());

			default:
				return e.map(cgs_mapper.bind(_, src));
		}
	}
	
	/* shorthand method to build an expression from an ExprDef and a Position */
	private static function toexpr(d:ExprDef, p:Position):Expr {
		return {expr: d, pos: p};
	}
#end
}
