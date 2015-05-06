package tannus.nore;

import tannus.nore.Check;
import tannus.nore.Token;
import tannus.nore.Value;

using StringTools;
using Lambda;

class Parser {
	//- Array of Tokens we'll be parsing
	public var tokens : Array<Token>;

	//- Array of Checks generated by [this] Parser
	public var ast : Array<Check>;

	public function new():Void {
		this.reset();
	}

/* === Instance Methods === */
	
	/**
	  * Parses Value Tokens
	  */
	public function parseValue(vt : Token):Value {
		switch (vt) {
			/* == [LITERALS] == */
			case Token.TNumber(num):
				return Value.VNumber(num);

			case Token.TString(str), Token.TIdent(str):
				return Value.VString(str);
			
			
			/* == [REFERENCE] == */
			case Token.TRefence( tew ):
				//- What is it a reference "tew"?
				switch (tew) {
					//- a field
					case Token.TIdent(id):
						return Value.VFieldReference(id);

					//- an index
					case Token.TNumber(num):
						var i:Int = Std.int( num );
						return Value.VIndexReference( i );

					default:
						throw 'SyntaxError: Cannot parse $tew to a Reference!';
				}

			/* == [TUPLE] == */
			case Token.TTuple( sets ):
				var values:Array<Value> = [for (set in sets) parseValue(set[0])];

				return Value.VTuple( values );


			//- Anything Else
			default:
				throw 'ValueError: Cannot parse $vt to a Value!';
		}
	}

	/**
	  * Parses and returns the next Check instance
	    - optionally accepts argument [last], being the last Check parsed,
	      which would pass itself to the next iteration in the case of 
	      Checks which can have different behaviour when immediately followed by particular tokens
	  */
	public function parseNext(?last : Check):Null<Check> {
		//- Attempt to obtain the next Token
		var tk = token();

		//- If we get one
		if (tk != null) {
			//- Check what it is
			switch ( tk ) {
				//- Wildcard descriptor
				case Token.TAny:
					return Check.NoCheck;
				
				//- HashTag ID Verification
				case Token.THash:
					//- grab the next token
					var tid = token();

					//- If there wasn't one, then we're done
					if (tid == null) throw COMPLETION_ERROR;

					//- otherwise, assume that it is a Value-parsible token
					var val:Value = parseValue( tid );

					return Check.IDCheck( val );
					
					//- otherwise, determine what to do with that token
					switch ( tid ) {
						//- if it was either an identifier or a string
						case Token.TIdent(id), Token.TString(id):
							//- This is an ID check
							return Check.IDCheck(Value.VString( id ));

						case Token.TTuple( sets ):
							var val:Value = parseValue( tid );

						default:
							throw 'SyntaxError: Unexpected $tid';
					}

				//- Operators with Special Behavior
				case Token.TOperator( oper ):
					trace( oper );

					switch (oper) {
						//- NOT operator
						case '!':
							//- Get the next check
							var nxt:Null<Check> = parseNext();
							
							//- If there was a next check
							if (nxt != null) {
								return Check.InverseCheck( nxt );
							}
							//- If there wasn't
							else {
								throw 'SyntaxError: Unexpected EOI!';
							}
						
						//- OR operator
						case '|':
							trace( "FUCK FUCK FUCK!!" );
							//- Get the last check
							var last:Null<Check> = pop();
							
							//- if we got a last check
							if (last != null) {
								//- get the next Check
								var nxt:Null<Check> = parseNext();
								
								//- if we got the next Check
								if (nxt != null) {
									/**
									  * At this point, we have both the "last" Check and the "next"
									  * one, effectively the left and right operands of this OR statement
									  */
									return Check.EitherCheck(last, nxt);
								}

								//- if no next Check was found
								else {
									throw 'SyntaxError: Unexpected end of input!';
								}
							} 
							//- if we didn't get a "last" Check
							else {
								throw 'SyntaxError: Unexpected "|"!';
							}

						//- ANY OTHER OPERATOR
						default:
							throw 'SyntaxError: Unexpected "$oper"!';
					}

				//- String/Identifier Type Verification
				case Token.TIdent(typename), Token.TString(typename):
					return Check.TypeCheck( typename );

				//- Field Value Checking
				case Token.TOBracket:
					var nodes:Array<Token> = new Array();
					var t = token();
					while (t != null) {
						switch (t) {
							case Token.TCBracket:
								break;

							default:
								nodes.push( t );
						}

						t = token();
					}
					if (nodes.length == 0) {
						throw 'SyntaxError: Expected Identifier, got null!';
					} else {
						var first:Token = nodes.shift();
						/* == Determine what to do from here == */
						switch ( first ) {
							//- In the case of an identifier
							case Token.TIdent(field):
								//- if that was the only token
								if (nodes.length == 0) {
									return Check.FieldExistsCheck(field);
								}

								//- Otherwise
								else {
									//- Grab the next token in the set
									var second:Token = nodes.shift();
									//- Figure out what to do with it
									switch (second) {
										//- If [second] is an operator
										case Token.TOperator(operation):
											/**
											  * Now, we assert that there is one more Token left,
											  * and then assert that said Token is a Value Token,
											  * not a Check Token
											  */
											if (nodes.length != 1) {
												throw 'SyntaxError: Expected Value, got $nodes';
											}
											else {
												var val:Token = nodes.shift();
												var value:Value = parseValue(val);

												return Check.FieldValueCheck(field, operation, value);
											}
										//- If [second] is ANYTHING ELSE
										default:
											throw 'SyntaxError: Expected Operator, got $second!';

									}
								}

							//- Anything Other Than Identifiers
							default:
								throw 'SyntaxError: Expected identifier, got $first';
						}
					}
				
				/**
				  * == [GROUPS] ==
				  */
				case Token.TGroup( subtree ):
					//- Parse the [subtree] in an AST of Checks
					var ast:Array<Check> = parse( subtree );

					//- Create and return a GroupCheck
					return Check.GroupCheck( ast );

				/**
				  * == [HELPER FUNCTION CALLS ==
				  */
				case Token.TColon:
					//- Get the next Token
					var nxt:Null<Token> = token();

					//- If there was no next Token
					if (nxt == null) {
						//- Complain about it
						throw 'SyntaxError: Unexpected end of input';
					}

					//- if we did get one
					else {
						//- determine what we should do with it
						switch ( nxt ) {
							//- If we got an identifier
							case Token.TIdent( id ):
								var check:Check = Check.HelperCheck( id );
								return check;

							//- If we got a call
							case Token.TCall(id, pargs):
								//- Declare our array of Values
								var args:Array<Value> = new Array();

								//- parse [pargs] as a Value
								var v:Value = parseValue(Token.TTuple(pargs));

								//- Ensure that it's a Tuple (though it's virtually impossible that it wouldn't be)
								switch (v) {
									//- Assuming that it is
									case Value.VTuple( vals ):
										args = vals;

									//- if by some chance it isn't
									default:
										throw 'WhatTheFuckError: While parsing the arguments of a function-call, a $v was encountered rather than a tuple';
								}
								
								//- Declare our Check
								var check:Check = Check.HelperCheck(id, args);

								//- Return it
								return check;

							
							//- Anything else
							default:
								//- Complain about it
								throw 'SyntaxError: Unexpected $nxt!';

						}
					}

				/**
				  * == [TUPLES] ==
				  */
				case Token.TTuple( sets ):
					//- An Array of all Values
					var values:Array<Value> = new Array();

					//- For every token-tree in [sets]
					for (set in sets) {
						//- get the first token
						var t:Token = set[0];

						//- parse it to a Value
						var v:Value = parseValue( t );
						
						//- add that shit to the stack
						values.push( v );
					}

					return Check.TupleCheck( values );

				/**
				  * == [TERNARY OPERATOR] ==
				  */
				case Token.TQuestion:
					//- Grab the last Check
					var prev = this.pop();

					//- If there is no previous Check
					if (prev == null) {
						//- Complain about it
						throw 'SyntaxError: Unexpected "?"!';
					}
					
					//- Now, get the next Check
					var ifTrue:Null<Check> = parseNext();

					//- If we don't get anything
					if (ifTrue == null) {
						//- Complain about that too
						throw 'SyntaxError: Unexpected end of input!';
					}

					var sep:Null<Token> = token();
					if (sep == null)
						throw 'Unexpected end of input!';
					
					//- Determine what [sep] is
					switch (sep) {
						//- if it's a colon
						case Token.TColon:
							//- Get the [ifFalse] condition
							var ifFalse:Null<Check> = parseNext();

							//- If that doesn't exist
							if (ifFalse == null)
								//- Ignore this
								ifFalse = Check.NoCheck;

							return Check.TernaryCheck(prev, ifTrue, ifFalse);
						
						//- if it's anything else
						default:
							//- complain about it
							throw 'SyntaxError: Unexpected $sep!';
					}


				default:
					throw 'SyntaxError: No directives for handling $tk';
			}
		}

		//- If we don't
		else {
			throw COMPLETION_ERROR;
		}
	}

	/**
	  * Parse a "tree" of Tokens, creating and returning an Array of Checks
	  */
	public function parseTree(tree : Array<Token>):Array<Check> {
		reset();
		this.tokens = tree;
		
		//- Initiate an "infinite" loop
		while (true) {
			//- Attempt to ..
			try {
				//- request a new Check
				var check = parseNext();

				//- If we get one
				if (check != null) {
					//- Push that shit onto the Stack
					push( check );
				}

			} 
			
			//- Should any of that fail, grab the error
			catch (err : String) {
				//- If that error is our completion signal
				if (err == COMPLETION_ERROR) {
					//- Break the infinite loop
					break;
				}
				
				//- For any other error
				else {
					//- Rethrow it
					throw err;
				}
			}
		}

		return this.ast;
	}

/* == Private Utility Methods == */
	/**
	  * "reset"s the state of [this] Parser
	  */
	public inline function reset():Void {
		this.tokens = new Array();
		this.ast = new Array();
	}

	/**
	  * Gets the next Token from the Stack
	  */
	private inline function token():Null<Token> {
		return (tokens.shift());
	}

	/**
	  * Pushes a new Check onto the Stack
	  */
	private inline function push(check : Check):Void {
		ast.push( check );
	}

	/**
	  * "pop"s the last Check off of the Stack
	  */
	private inline function pop():Null<Check> {
		return ast.pop();
	}


/* === Class Methods === */
	
	/**
	  * Class-Level Method to quickly parse a token-tree and return the result
	  */
	public static function parse(tree : Array<Token>):Array<Check> {
		var parser = new Parser();
		return parser.parseTree( tree );
	}

/* === Class Fields === */

	//- The Error the be Thrown Upon Reaching the End-Of-Input
	private static inline var COMPLETION_ERROR:String = '@>EOI<@';
}