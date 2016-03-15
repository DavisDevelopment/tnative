package tannus.macro;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

using haxe.macro.ExprTools;
using haxe.macro.ExprTools.ExprArrayTools;

class MacroTools {
	/**
	  * get the given a Pointer to the given Expression
	  */
	public static macro function asReference<T>(e : ExprOf<T>):ExprOf<tannus.io.Ptr<T>> {
		var ref:Expr = pointer( e );
		return macro $ref;
	}

	#if macro

	/**
	  * Replace all references to '_' with [repl]
	  */
	public static function mapUnderscoreTo(e:Expr, repl:String):Expr {
		var erep = parse( repl );
		switch ( e.expr ) {
			case EConst(CIdent( '_' )):
				return erep;
			default:
				return e.map(map_us.bind(_, erep));
		}
	}

	/**
	  * Check whether the given Expression contains a return
	  */
	public static function hasReturn(e : Expr):Bool {
		var ret:Bool = false;
		
		function walker(ee : Expr):Void {
			switch ( ee.expr ) {
				case ExprDef.EReturn( _ ):
					ret = true;

				default:
					null;
			}
		}
		
		e.iter( walker );
		
		return ret;
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

	/**
	  * all interfaces implemented by the given classtype
	  */
	public static function classHierarchy(ct : ClassType):Array<ClassType> {
		var results:Array<ClassType> = new Array();
		if (ct.superClass != null) {
			var parent = ct.superClass.t.get();
			results.push( parent );
			results = results.concat(classHierarchy( parent ));
		}
		return results;
	}

	/**
	  * check whether [ctype] is a subclass of [base]
	  */
	public static function subClassOf(ctype:ClassType, base:ClassType):Bool {
		if (!base.isInterface) {
			var hier = classHierarchy( ctype );
			for (c in hier) {
				if (c.pack.join('.') == base.pack.join('.')) {
					return true;
				}
			}
			return false;
		}
		else return false;
	}

	/**
	  * get the full name of the given class-type
	  */
	public static function fullName(ct : ClassType):String {
		return ct.pack.concat([ct.name]).join('.');
	}

	#end
}
