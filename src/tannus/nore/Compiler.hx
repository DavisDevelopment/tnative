package tannus.nore;

import tannus.nore.Check;
import tannus.nore.Value;
import tannus.internal.TypeTools;

/**
  * Class to compile a List of Check instances to "checker functions"
  */
class Compiler <T> {
	//- Check Functions created by [this] Compiler
	public var functions : Array<CheckFunction<T>>;

	//- List of [Check]s
	public var checks : Array<Check>;

	//- Map of Operators
	public var operators : Map<String, OperatorFunction<Dynamic, Dynamic, Dynamic>>;

	//- Map of Helper-Functions
	public var helpers : Map<String, HelperFunctionWrapper<T>>;

	/**
	  * Constructor
	  */
	public function new():Void {
		reset();
		
		operators = new Map();
		helpers = new Map();

		initializeOperators();
		initializeHelpers();
	}

/* == Instance Methods == */

	/**
	  * "push" a new CheckFunction onto the Stack
	  */
	public inline function push(checker : CheckFunction<T>):Void {
		functions.push( checker );
	}

	/**
	  * "registers" an operator function on [this] Compiler
	  */
	public inline function operator(symbol:String, func:OperatorFunction<Dynamic, Dynamic, Dynamic>):Void {
		operators[symbol] = func;
	}

	/**
	  * Initializes all operator functions
	  */
	public inline function initializeOperators():Void {
		//- Create equality operator
		operator('==', function(left:Dynamic, right:Dynamic):Dynamic {
			/**
			  * This will eventually be more fleshed out, accounting for things like arrays and enums,
			  * but for now this will do
			  */
			return (left == right);
		});

		//- Create inverted equality operator
		op(this, '!=', (left != right));

		//- Create greater-than operator
		op(this, '>', (left > right));

		//- Create less-than operator
		op(this, '<', (left < right));
		
		//- Create greater-than-or-equal operator
		op(this, '>=', (left >= right));
		
		//- Create less-than-or-equal operator
		op(this, '<=', (left <= right));

	}

	/**
	  * Shorthand for declaring a helper function
	  */
	public inline function helper(name:String, func:HelperFunction<T>):Void {
		//- Declare our wrapper function which will decode the Values passed to it as arguments
		var wrapper = (function(target:T, vargs:Array<Value>):Bool {

			//- Create an empty array of Dynamics
			var args:Array<Dynamic> = new Array();

			//- Iterate over the Values
			for (val in vargs) {
				//- Compile the getter-function from the Value
				var getter = compileValue( val );

				//- Invoke the getter, retrieving the result
				var result:Dynamic = getter( target );
				
				//- Push that result onto the Stack
				args.push( result );
			}
			
			//- Return the result of invoking [func] with [target] as it's first argument, and [args] as it's second
			return func((cast target), args);
		});

		helpers[name] = wrapper;
	}

	/**
	  * Initializes all helper functions
	  */
	public inline function initializeHelpers():Void {
		//- Utility function for determining if an object is iterable, and if so, returning it's iterator
		function iterate(o : Dynamic):Null<Iterator<Dynamic>> {
			//- Attempt to retrieve [o]'s iterator field
			var iter:Null<Dynamic> = Reflect.getProperty(o, 'iterator');
			
			//- if one was found, check that it's a function
			if (iter != null) {
				var callable:Bool = Reflect.isFunction( iter );
				if (callable) {
					//- Attempt to return the result of [iter], cast as an Iterator
					try {
						var res:Dynamic = Reflect.callMethod(o, iter, []);
						
						//- Check that [res] isn't null
						if (res != null) {
							//- if not null, return [res] (UNSAFELY)
							return (untyped res);
						}

						//- If it is null
						else {
							return null;
						}
					}

					//- Should this fail
					catch (err : String) {
						//- Return null
						return null;
					}
				}

				//- if it's not a function
				else {
					return null;
				}
			}

			//- Otherwise
			else {
				return null;
			}
		}

		/**
		  * Helper function for determining whether any of [args] exists "in" [o]
		  */
		var has = (function(o:T, args:Array<Dynamic>):Bool {
			//- if [o] is a String
			if (Std.is(o, String)) {
				var str:String = Std.string( o );

				//- Check that at least one item in [args] is a substring of [o]
				for (a in args) {
					var s:String = Std.string( a );
					
					if (str.indexOf(s) != -1) {
						return true;
					}
				}

				return false;
			}

			//- Othwerwise
			else {
				//- Attempt to get the iterator of [o]
				var iter:Null<Iterator<Dynamic>> = iterate( o );
				
				//- If it's iterable
				if (iter != null) {
					var values:Array<Dynamic> = [for (x in iter) x];
					
					for (a in args) {
						if (Lambda.has(values, a)) {
							return true;
						}
					}

					return false;
				}

				//- If it's not
				else {
					return false;
				}
			}
		});

		//- Now actually register it
		helper('has', has);
		helper('contains', has);
	}
	
	/**
	  * "compile"s a Value getter
	  */
	public function compileValue(value : Value):ValueFunction<T> {
		switch (value) {
			//- Literal Numbers
			case Value.VNumber(num):
				return (function(o:T) return num);

			//- Literal Strings
			case Value.VString(str):
				return (function(o:T) return str);

			//- Tuples
			case Value.VTuple( vals ):
				var vgetters = [for (v in vals) compileValue(v)];

				return (function(o : T) {
					return ([for (f in vgetters) f(o)]);
				});

			//- Field Reference
			case Value.VFieldReference(field):
				var getter = Reflect.getProperty.bind(_, field);

				return (function(o : T) {
					return getter( o );
				});

			//- Index Reference
			case Value.VIndexReference( index ):
				return (function(o : T) {
					try {
						var arr:Array<Dynamic> = cast(o, Array<Dynamic>);
						
						return (arr[ index ]);
					} catch (err : String) {
						try {
							var s:Dynamic = cast o;
							return s.charAt(index);

						} catch (err : String) {
							throw 'TypeError: Cannot access index $index of $o!';
						}
					}
				});

			//- Anything else
			default:
				throw 'Unable to handle $value!';
		}
	}

	/**
	  * "compiles" a Value to a function to test for equality to a given value
	  */
	public function compileValueChecker(val : Value, checker:Dynamic->Dynamic->Bool):T->Dynamic->Bool {
		//- Determine what kind of Value [val] is
		switch ( val ) {
			// === [NUMBERS] ===
			case Value.VNumber( num ):
				return (function(o:T, v:Dynamic):Bool {
					return (checker(v, num));
				});

			// === [STRINGS] ===
			case Value.VString( str ):
				return (function(o, v):Bool {
					return (checker(v, str));
				});

			// === [TUPLES] ===
			case Value.VTuple( vals ):
				//- Get the list of ValueChecker functions
				var vgetters = [for (vv in vals) compileValue(vv)];

				//- Create and return the function
				return (function(o, v):Bool {
					for (f in vgetters) {
						var validated:Bool = checker(v, f(o));
						if (!validated) {
							return false;
						}
					}

					return true;
				});

			// === Field Index Reference ===
			case Value.VArrayAccess(field, index):
				var getter = compileValue( val );

				return function(o, v):Bool {
					var p:Dynamic = getter( o );

					return (checker(v, p));
				};


			// === [FIELD REFERENCE] ===
			case Value.VFieldReference( field ):
				var getter = compileValue( val );

				return function(o, v):Bool {
					var p:Dynamic = getter( o );

					return (checker(v, p));
				};

			// === [] ===
			case Value.VIndexReference( index ):
				var getter = compileValue( val );
				
				return (function(o, v):Bool {
					var p:Dynamic = getter(o);

					return (checker(v, p));
				});
		}
	}

	/**
	  * "compile"s the next Check
	  */
	public function compileCheck(check : Check):CheckFunction<T> {

		//- Determine what to do with [check]
		switch ( check ) {

			//- In the case of a (*) wildcard
			case Check.NoCheck:
				//- return a function which always returns true
				return (function(o : T):Bool {
					return true;
				});
			
			//- Check the "id" field
			case Check.IDCheck( id ):
				return check_id(id).bind(_);
			
			//- Check the Type
			case Check.TypeCheck( typename ):
				return type_check(typename).bind(_);

			//- Check that [field] exists
			case Check.FieldExistsCheck( field ):
				return field_exists_check(field).bind(_);

			//- Validate the value of [field]
			case Check.FieldValueCheck(field, operation, val):
				return field_value_check(field, operation, val).bind(_);

			//- Check that [check] doesn't validate
			case Check.InverseCheck( check ):
				var checker = compileCheck(check);

				return (function(o : T):Bool {
					return (!checker( o ));
				});

			//- Check that either [one] or [two] validates
			case Check.EitherCheck(one, two):
				var oner = compileCheck(one);
				var twoer = compileCheck(two);

				return (function(o : T):Bool {
					return (oner(o) || twoer(o));
				});

			//- Check a group of Checks
			case Check.GroupCheck( subs ):
				var checker = compile( subs );

				return checker;
			
			//- Check if [con] validates, and if so, validate [ifTrue], else validate [ifFalse]
			case Check.TernaryCheck(conCheck, ifTrueCheck, ifFalseCheck):
				var con = compileCheck(conCheck);
				var ifTrue = compileCheck(ifTrueCheck);
				var ifFalse = compileCheck(ifFalseCheck);

				return (function(o : T):Bool {
					return (con(o) ? ifTrue(o) : ifFalse(o));
				});

			//- Check that the helper function referred to [helper] both exists, and validates
			case Check.HelperCheck(helper, vargs):
				//- Declare the array which we will pass as the 'arguments' to helper-function
				var args:Array<Value> = new Array();

				//- if [vargs] is not [null]
				if (vargs != null) {
					args = vargs;
				}
				
				//- Create and return a new CheckFunction
				return (function(o : T):Bool {
					//- If [helper] is a valid helper-function
					if (helpers.exists( helper )) {
						//- Retrieve the helper-function from the Dictionary
						var func = helpers.get( helper );
						
						//- Ensure that it is a valid function
						if (Reflect.isFunction( func )) {
							//- Wrap the invokation in try-catch statement, to ensure to breakage
							try {
								var result:Bool = func(o, args);
								
								return result;
							} 
							
							//- If there were issues with the invokation
							catch (err : String) {
								trace( 'Error invoking Helper-Function: $err' );

								return false;
							}
						}

						//- if [func] is not a function
						else {
							//- Just return false
							return false;
						}
					}

					//- if [helper] isn't a helper-function at all
					else {
						//- First, check if [helper] is a property of [o]
						var prop:Dynamic = Reflect.getProperty(o, helper);

						//- If that's not [null]
						if (prop != null) {
							//- If it's a function
							if (Reflect.isFunction(prop)) {
								//- Attempt to invoke [prop] as a method of [o] with [args] as it's arguments
								try {
									//- Get the result of this invokation
									var dyn_result:Dynamic = Reflect.callMethod(o, prop, args);

									//- if that result is null
									if (dyn_result == null) {
										return false;
									}

									//- Otherwise, cast it to Bool
									return (dyn_result == true);
								}

								//- If that fails
								catch (err : String) {
									
									//- Just return false
									return false;
								}
							}

							//- if it's not a function, then it's a field
							else {
								//- Determine the type of this field
								var typ:String = TypeTools.typename( prop );
								
								//- Determine how to handle [prop]
								switch (typ) {
									//- Numbers: (n <= 0) = FALSE, (n > 0) = TRUE
									case 'Number':
										return (prop > 0);
									
									//- Boolean, self-explanatory
									case 'Bool':
										return (prop == true);

									//- Anything else, simply return true
									default:
										return true;
								}
							}
						}

						//- If it was null
						else {
							
							//- Just return false
							return false;
						}
					}
				});
				


			default:
				throw 'UnknownCheckError: Cannot compile $check!';

		}
	}

	/**
	  * "compile"s an AST of Checks
	  */
	public function compileAST(ast : Array<Check>):CheckFunction<T> {
		//- "reset" the current state of [this] Compiler
		reset();
		//- Absorb the given "ast"
		this.checks = ast;
		
		//- Compile all Checks into CheckFunctions
		for (check in checks) {
			var func:CheckFunction<T> = compileCheck( check );
			
			//- Push them onto our "functions" stack
			push( func );
		}
		
		/**
		  * Return a function which will iterate through all functions,
		  * and for each one, invoke it on the provided argument [o],
		  * and if the result is [false], return false.
		  * Should all functions return [true] for [o], return true
		  */
		return (function(o : T):Bool {
			for (f in functions) {
				var passed:Bool = f( o );
				if (!passed) {
					return false;
				}
			}

			return true;
		});
	}

/* == Inline Utility Methods == */

	/**
	  * "reset"s [this] Compiler's internal state
	  */
	private inline function reset():Void {
		this.functions = new Array();
		this.checks = new Array();
	}

/* == Non-Inline Utility Methods == */
	
	/**
	  * Checks that the "id" field of [o], if present, matches [id]
	  */
	public dynamic function check_id <T> (id : Value):CheckFunction<T> {
		//- Whether the test succeeded
		var success:Bool = false;

		//- The test
		var checker = function(l:Dynamic, r:Dynamic):Bool {
			var r:Bool = (l == r);
			if (r) {
				success = true;
			}

			return r;
		};

		var idcheck = compileValueChecker(id, checker);

		return function(o : T):Bool {
			success = false;

			var id:String = (Std.string(Reflect.getProperty(o, 'id')));
			
			idcheck((cast o), id);

			return (success);
		};
	}
	
	/**
	  * Checks whether the type of [o] matches [typename]
	  */
	public dynamic function type_check <T> (typename : String):CheckFunction<T> {
		return function(o : T):Bool {
			return (TypeTools.typename(o) == typename);
		};
	}

	/**
	  * Checks that field [field] of object [o] exists and is not [null]
	  */
	public dynamic function field_exists_check(field : String):CheckFunction<T> {
		var getter = Reflect.getProperty.bind(_, field);
		return (function(o : T):Bool {
			return (getter(o) != null);
		});
	}

	/**
	  * Checks that the result of operator [op] applied to
	  * field [field] of object [o] and [value] is [true]
	  */
	public dynamic function field_value_check(field:String, op:String, value:Value):CheckFunction<T> {
		var fgetter = Reflect.getProperty.bind(_, field);
		var opfunc:Null<OperatorFunction<Dynamic, Dynamic, Bool>> = operators[op];
		var vgetter = compileValue(value);

		return (function(o : T):Bool {
			return (opfunc(fgetter(o), vgetter(o)));
		});
	}

	/**
	  * Macro shorthand for defining operator-functions
	  */
	public static macro function op(self, sym, action) {
		return macro {
			$self.operator($sym, function(left:Dynamic, right:Dynamic):Bool {
				return ($action);
			});
		};
	}

/* == Class-Level Utility Methods == */

	/**
	  * Quickly create a new Compiler and compile the given [ast]
	  */
	public static inline function compile <T> (ast : Array<Check>):CheckFunction<T> {
		var compiler:Compiler<T> = new Compiler();
		return compiler.compileAST( ast );
	}
}

private typedef CheckFunction <T> = T -> Bool;
private typedef ValueFunction <T> = T -> Dynamic;
private typedef OperatorFunction <Left, Right, Result> = Left -> Right -> Result;
private typedef HelperFunction <T> = T -> Array<Dynamic> -> Bool;
private typedef HelperFunctionWrapper <T> = T->Array<Value>->Bool;
