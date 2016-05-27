package tannus.macro;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;
using haxe.macro.ExprTools;
using haxe.macro.ExprTools.ExprArrayTools;
using haxe.macro.TypeTools;
using haxe.macro.ComplexTypeTools;

class MacroTools {
	/**
	  * create a Getter to the given Expression
	  */
	public static macro function asGetter<T>(e : ExprOf<T>):ExprOf<tannus.io.Getter<T>> {
		e = macro tannus.io.Getter.create( $e );
		return macro $e;
	}

	/**
	  * create a Setter to the given Expression
	  */
	public static macro function asSetter<T>(e : ExprOf<T>):ExprOf<tannus.io.Setter<T>> {
		e = macro tannus.io.Setter.create( $e );
		return macro $e;
	}

	/**
	  * get the given a Pointer to the given Expression
	  */
	public static macro function asReference<T>(e : ExprOf<T>):ExprOf<tannus.io.Ptr<T>> {
		var ref:Expr = pointer( e );
		return macro $ref;
	}

	/**
	  * Create and `throw` and Error from the given String expression
	  */
	public static macro function report(message : ExprOf<String>):Expr {
		return macro throw new tannus.utils.Error( $message );
	}

	#if macro

	/**
	  * Check the given Expr for errors
	  */
	public static function test(e : Expr):Null<Dynamic> {
		var s = e.toString();
		try {
			var pe = Context.parse(s, e.pos);
			return null;
		}
		catch (error : Dynamic) {
			return error;
		}
	}

	/**
	  * Check whether [e] is a constant or not
	  */
	public static function isConstant(e : Expr):Bool {
		switch ( e.expr ) {
			case EConst(_):
				return true;
			default:
				return false;
		}
	}

	/**
	  * Build a function expression with [body] as the function body
	  */
	public static function buildFunction(body:Expr, args:Array<String>, noreturn:Bool=false):Expr {
		/* = format the function body = */
		/* if [body] does not contain a 'return' statement */
		if (!hasReturn( body ) && !noreturn) {
			/* convert the last expression in the body to a return expression */
			var abody:Array<Expr> = toArray( body );
			var last = abody.pop();
			last = (macro return $last);
			abody.push( last );
			body = fromArray( abody );
		}

		// build the function arguments
		var fargs:Array<FunctionArg> = args.map( functionArg );
		
		// build the function object
		var func:Function = {
			args   : fargs,
			expr   : body,
			ret    : null,
			params : null
		};

		// return the function expression
		return {
			expr: EFunction(null, func),
			pos: Context.currentPos()
		};
	}

	/**
	  * Build a function argument from the given String
	  */
	public static function functionArg(s : String):FunctionArg {
		var arg:FunctionArg = {
			value : null,
			type  : null,
			opt   : false,
			name  : 'arg'
		};

		/* optional */
		//if (s.startsWith('?')) {
			//s = s.after('?');
			//arg.opt = true;
		//}

		/* type specified */
		//if (s.has(':')) {
			//var type = s.after(':');
			//s = s.before(':');
			//if (type.has('=')) {
				//var val = type.after('=');
				//type = type.before('=');
				//s += ('=' + val);
			//}
			//var ctype:ComplexType = Context.getType( type ).toComplexType();
			//trace(ctype);
			//arg.type = ctype;
		//}

		/* default value */
		//if (s.has('=')) {
			//var sval = s.after('=');
			//s = s.before('=');
			//var value:Expr = Context.parse(sval, Context.currentPos());
			//arg.value = value;
		//}

		arg.name = s;

		return arg;
	}

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
	  * Replace all references to '_' with [repl]
	  */
	public static function mapUnderscoreToExpr(e:Expr, repl:Expr):Expr {
		switch ( e.expr ) {
			case EConst(CIdent( '_' )):
				return repl;
			default:
				return e.map(map_us.bind(_, repl));
		}
	}

	/**
	  * Replace all instances of [what] with [with] in [e]
	  */
	public static function replace(e:Expr, what:Expr, with:Expr):Expr {
		if (e.expr.equals( what.expr )) {
			return with;
		}
		else {
			return e.map(replacer.bind(_, [what], with));
		}
	}

	/**
	  * Replace all instances of the items in [whats] with [with]
	  */
	public static function replaceMultiple(e:Expr, whats:Array<Expr>, with:Expr):Expr {
		return e.map(replacer.bind(_, whats, with));
	}

	
	public static function has(e:Expr, what:Expr):Bool {
		if (e.expr.equals( what.expr )) {
			return true;
		}
		else {
			var ret:Bool = false;
			function finder(ee : Expr):Void {
				if (ee.expr.equals( what.expr )) {
					throw true;
				}
				else ee.iter( finder );
			}
			try {
				e.iter( finder );
				return ret;
			}
			catch (err : Bool) {
				return err; 
			}
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

	/*
	public static function setter<T>(e : ExprOf<T>):ExprOf<tannus.io.Setter<T>> {
		return (macro tannus.io.Setter.create( $e ));
	}

	public static function getter<T>(e : ExprOf<T>):ExprOf<tannus.io.Getter<T>> {
		return (macro tannus.io.Getter.create( $e ));
	}
	*/

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
	  * replacer function
	  */
	private static function replacer(e:Expr, whats:Array<Expr>, with:Expr):Expr {
		var mapper = replacer.bind(_, whats, with);

		for (what in whats) {
			if (e.expr.equals( what.expr )) {
				return with;
			}
		}

		return e.map( mapper );
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
		var a = ct.pack;
		if (ct.module != '' && ct.name != ct.module)
			a.push( ct.module );
		a.push( ct.name );
		return a.join('.');
	}

	/**
	  * convert the given Expr to an Array<Expr> 
	  */
	public static function toArray(e : Expr):Array<Expr> {
		switch ( e.expr ) {
			case EBlock( list ):
				return list;

			default:
				return [e];
		}
	}

	/**
	  * Create a Block expression from an Array of expressions
	  */
	public static function fromArray(list : Array<Expr>):Expr {
		return macro $b{ list };
	}

	#end
}
