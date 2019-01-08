package tannus.nore;

import tannus.ds.Stack;
import tannus.internal.TypeTools in Tt;

import tannus.nore.Check;

import Std.*;

using Lambda;
using tannus.ds.ArrayTools;
using tannus.ds.MapTools;
using tannus.nore.ValueTools;
using StringTools;
using tannus.ds.StringUtils;

class Compiler {
	/* Constructor Function */
	public function new():Void {
		reset();
	}

/* === Instance Methods === */

	/**
	  * Compile the given String into a CheckFunction
	  */
	public function compileString(s : String):CheckFunction {
		var l = new Lexer();
		for (s in operators.keys()) {
			l.op( s );
		}
		var p = new Parser();
		var toks = l.lex( s );
		var tree = p.parse( toks );
		return compile( tree );
	}

	/**
	  * Compile [checkList] to a CheckFunction
	  */
	public function compile(checkList : Array<Check>):CheckFunction {
		checks = new Stack( checkList );

		while ( !end ) {
			var cf:CheckFunction = compileCheck(checks.pop());
			checkFuncs.push( cf );
		}

		return testAll.bind(_);
	}

	/**
	  * Compile the next Check
	  */
	private function compileCheck(check : Check):CheckFunction {
		switch ( check ) {
			/* == Grouped Checks == */
			case GroupCheck( list ):
				var state = save();
				var child = new Compiler();
				child.restore( state );
				return child.compile( list );

			/* == Type Check == */
			case TypeCheck( type ):
				return tools.checkType.bind(_, type, false);

			/* == Loose Type Check == */
			case LooseTypeCheck( type ):
				return tools.checkType.bind(_, type, true);

			/* == Shorthand Type Check == */
			case ShortTypeCheck( type ):
				return tools.checkShortType.bind(_, type);

			/* == Nested Check == */
			case NestedCheck(sop, value):
				if (operators.exists( sop )) {
					var op:OperatorFunction = operators.get( sop );
					return function(o : Dynamic):Bool {
						return op(o, value.haxeValue(tools, o).get());
					};
				}
				else {
					throw 'CompilationError: Invalid operator "$sop"!';
				}

			/* == Existential Field Check == */
			case FieldExistsCheck( name ):
				return tools.has.bind(_, name);

			/* == Field Value Check == */
			case FieldValueCheck(sop, name, value):
				if (operators.exists( sop )) {
					var op:OperatorFunction = operators.get(sop);
					return function(o : Dynamic):Bool {
						return op(tools.get(o, name), value.haxeValue(tools, o).get());
					};
				}
				else {
					throw 'CompilationError: Invalid operator "$sop"!';
				}

			/* == Field Type Check == */
			case FieldValueTypeCheck(name, type, loose):
				return function(o : Dynamic):Bool {
					return tools.checkType(tools.get(o, name), type, loose);
				};

			/* == Field Check Block == */
			case FieldValueBlockCheck(name, block):
				var getit = tools.get.bind(_, name);
				var test = sub( block );
				return function(o : Dynamic):Bool {
					var ctx = getit( o );
					return (test( ctx ));
				};

			/* == Helper Function Check == */
			case HelperCheck(name, vargs):
				return tools.helper_check.bind(_, name, vargs);

			/* == OR Check == */
			case EitherCheck(cleft, cright):
				var left = compileCheck( cleft );
				var right = compileCheck( cright );
				return function(o : Dynamic):Bool {
					return (left( o ) || right( o ));
				};

			/* == NOT Check == */
			case InvertedCheck( cc ):
				var c = compileCheck( cc );
				return function(o : Dynamic):Bool {
					return !c( o );
				};

			/* == Ternary Check == */
			case TernaryCheck(ccondition, ctrue, cfalse):
				var cond = compileCheck( ccondition );
				var itrue = compileCheck( ctrue );
				var ifalse = (cfalse != null ? compileCheck(cfalse) : null);
				return function(o : Dynamic):Bool {
					if (cond( o )) {
						return itrue( o );
					}
					else {
						if (ifalse != null) {
							return ifalse( o );
						}
						else {
							return true;
						}
					}
				};

			default:
				throw 'CompilationError: Unable to compile $check!';
		}
	}

	/**
	  * Restore [this] to it's default state
	  */
	private function reset():Void {
		checks = new Stack();
		checkFuncs = new Array();
		try {
			operators.exists('');
		} catch (error : Dynamic) {
			operators = new Map();
		}
		try {
			helpers.exists('');
		} catch (error : Dynamic) {
			helpers = new Map();
		}
		tools = new CompilerTools( this );

		initOperators();
		initHelpers();
	}

	/**
	  * Build out the [operators] Map
	  */
	private function initOperators():Void {
		/* == Equality Check == */
		function eq(x:Dynamic, y:Dynamic):Bool {
			if (Tt.typename(x) == Tt.typename(y)) {
				if (x == y) {
					return true;
				}
				else {
					var eq:Null<Dynamic> = tools.get(x, 'equals');
					if (Reflect.isFunction(eq)) {
						try {
							var eqv:Dynamic = Reflect.callMethod(x, eq, [y]);
							if (eqv != null) {
								return (eqv == true);
							}
						}
						catch (err : Dynamic) {
							null;
						}
					}

					var eq:Null<Dynamic> = tools.get(y, 'equals');
					if (Reflect.isFunction(eq)) {
						try {
							var eqv:Dynamic = Reflect.callMethod(y, eq, [x]);
							if (eqv != null) {
								return (eqv == true);
							}
						}
						catch (err : Dynamic) {
							null;
						}
					}
					return false;
				}
			}
			else {
				return false;
			}
		}
		oper('==', eq);
		oper('!=', function(x:Dynamic, y:Dynamic):Bool {
			return !eq(x, y);
		});

		function greaterThan(x:Dynamic, y:Dynamic):Bool {
			if (Tt.typename(x) == 'Number' && Tt.typename(y) == 'Number') {
				return (x > y);
			}
			else 
				return false;
		}
		function lessThan(x:Dynamic, y:Dynamic):Bool {
			if (Tt.typename(x) == 'Number' && Tt.typename(y) == 'Number') {
				return (x < y);
			}
			else 
				return false;
		}

		oper('>', greaterThan);
		oper('<', lessThan);
		oper('>=', function(x, y) {
			return (greaterThan(x, y) || eq(x, y));
		});
		oper('<=', function(x, y) {
			return (lessThan(x, y) || eq(x, y));
		});
		
		function has(x:Dynamic, y:Dynamic):Bool {
			if (is(x, String)) {
				return (cast(x, String).has(string(y)));
			}
			else if (is(x, Array)) {
				return (cast(x, Array<Dynamic>).has(y));
			}
			else {
				return false;
			}
		}
		oper('has', has);
		oper('contains', has);

		function regtest(x:Dynamic, y:Dynamic):Bool {
			switch ([x, y].map(Tt.typename.bind(_))) {
				case [_, 'String']:
					var reg:EReg = new EReg(string( y ), '');
					return reg.match(string( x ));

				default:
					return false;
			}
		}

		oper('~=', regtest);
	}

	/**
	  * Build out the [helpers] Map
	  */
	private function initHelpers():Void {
		null;
	}

	/**
	  * Add a new operator
	  */
	public inline function oper(name:String, f:OperatorFunction):Void {
		operators.set(name, f);
	}

	/**
	  * Add a new helper
	  */
	public inline function helper(name:String, f:HelperFunction):Void {
		helpers.set(name, f);
	}


	/**
	  * Get the current State of [this] Compiler
	  */
	private function save():State {
		return {
			'checks': checks.copy(),
			'checkFuncs': checkFuncs.copy(),
			'operators': copyOperators(),
			'helpers': copyHelpers(),
			'tools': tools
		};
	}

	/**
	  * Restore [this] Compiler to a previous State
	  */
	private function restore(s : State):Void {
		checks = s.checks;
		checkFuncs = s.checkFuncs;
		operators = s.operators;
		helpers = s.helpers;
		tools = s.tools;
	}

	/**
	  * Compile a sub-tree
	  */
	private function sub(checkList : Array<Check>):CheckFunction {
		var subc = new Compiler();
		subc.tools = tools;
		subc.operators = copyOperators();
		subc.helpers = copyHelpers();
		var f = subc.compile( checkList );
		return f;
	}

	/**
	  * Create and return a copy of [operators]
	  */
	private function copyOperators():Map<String, OperatorFunction> {
		var copy = new Map();
		for (key in operators.keys())
			copy.set(key, operators.get(key));
		return copy;
	}

	/**
	  * Create and return a copy of [helpers]
	  */
	private function copyHelpers():Map<String, HelperFunction> {
		var copy = new Map();
		for (key in helpers.keys())
			copy.set(key, helpers.get(key));
		return copy;
	}

	/**
	  * The primary CheckFunction, which is returned by [compile]
	  */
	private function testAll(o : Dynamic):Bool {
		for (check in checkFuncs) {
			if (!check( o )) {
				return false;
			}
		}
		return true;
	}

/* === Computed Instance Fields === */

	/* whether we've reached the end of our input */
	private var end(get, never):Bool;
	private inline function get_end():Bool return checks.empty;

/* === Instance Fields === */

	private var checks : Stack<Check>;
	private var checkFuncs : Array<CheckFunction>;
	private var operators : Map<String, OperatorFunction>;
	private var helpers : Map<String, HelperFunction>;
	private var tools : CompilerTools;
}

private typedef State = {
	var checks : Stack<Check>;
	var checkFuncs : Array<CheckFunction>;
	var operators : Map<String, OperatorFunction>;
	var helpers : Map<String, HelperFunction>;
	var tools : CompilerTools;
};
