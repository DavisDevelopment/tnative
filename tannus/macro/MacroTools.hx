package tannus.macro;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

using haxe.macro.ExprTools;
using haxe.macro.ExprTools.ExprArrayTools;

class MacroTools {
	#if macro

	/**
	  * Replace all references to '_' with [repl]
	  */
	public static function mapUnderscoreTo(e:Expr, repl:String):Expr {
		var erep = parse( repl );
		return e.map(map_us.bind(_, erep));
	}

	/**
	  * Pointer-ify an expression
	  */
	public static function pointer<T>(e : ExprOf<T>):ExprOf<tannus.io.Ptr<T>> {
		return (macro tannus.io.Ptr.create( $e ));
	}

	/**
	  * Generate the (approximate) code for the given expression
	  */
	public static function code(e : Expr):String {
		return e.toString();
	}

	/**
	  * Map [_] to [repl]
	  */
	private static function map_us(e:Expr, replacement:Expr):Expr {
		var mapper = map_us.bind(_, replacement);
		switch ( e.expr ) {
			case EConst(CIdent('_')):
				return replacement;

			default:
				return e.map( mapper );
		}
	}

	/**
	  * Parse the given String into a Haxe expression
	  */
	private static function parse(s : String):Expr {
		return Context.parse(s, Context.currentPos());
	}

	#end
}
