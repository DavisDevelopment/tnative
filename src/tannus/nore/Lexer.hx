package tannus.nore;

//- NewORE Imports
import tannus.nore.Token;

//- IO Imports
import tannus.io.ByteArray;
import tannus.io.ByteInput;
import tannus.io.Byte;

import haxe.macro.Expr;

/* == Static Type-Extensions We'll Be Using == */
using Lambda;
using StringTools;

/**
  * Lexer class - Performs lexical analysis on a ByteArray to create a Node Tree
  */
class Lexer {
	public function new():Void {
		
	}
/* === Instance Fields === */
	
	//- The ByteInput [this] Lexer is currently reading from
	public var source : ByteInput;

	//- What [this] Lexer has lexed so far
	public var tree : Array<Token>;


/* === Instance Methods === */

	/**
	  * Attempt to retrieve the next token
	  */
	public function token(?last:Token):Null<Token> {
		//- Attempt to retrieve the next Byte of input
		try {
			
			var c:Byte = byte();
			log( c );
			
			/**
			  * Whitespace
			  */
			if (c.isWhiteSpace()) {
				return null;
			}
			
			/**
			  * Strings
			    - single-quote => 39
			    - double-quote => 34
			    - escape-slash => 92
			  */
			else if (c == 34 || c == 39) {
				//- reference to the code that started the string
				var delimiter:Byte = (c);
				//- variable to hold the String being created
				var str:String = '';
				//- whether the last byte was a slash ( \ )
				var escaped:Bool = false;
				
				//- Initiate a Loop
				while (true) {
					attemptByte(this, {
						log( bit );
						if (escaped) {
							str += bit;
							escaped = false;
						} else {
							//- Escape
							if (bit == 92) {
								escaped = true;
							}

							else if (bit == delimiter) {
								break;
							}

							else {
								str += bit;
							}
						}
					}, {
						throw 'Unterminated String';
					});
				}

				//- Create the Token and return it
				var tk:Token = Token.TString( str );

				return tk;
			}

			/**
			  * Identifiers
			  */
			else if (c.isLetter()) {
				//- Create variable to hold identifier
				var ident:String = (c + '');
				
				while (true) attemptByte(this, {
					if (bit.isAlphaNumeric()) {
						ident += bit;
					} else {
						source.back( bit );
						break;
					}
				}, {
					
					return Token.TIdent( ident );
				});

				var tk = Token.TIdent( ident );
				return tk;
			}

			/**
			  * === [NUMBERS] ===
			    + Formats:
			      - 0 => standard integer (50)
			      - 1 => standard double (50.0)
			      - 2 => standard hexidecimal (0x32)
			    + Byte-Codes:
			      - period => 46
			      - x      => 120
			  */
			else if (c.isNumeric()) {
				//- Create variable to store the string-representation of the number
				var num_str:String = (c + '');
				//- What format the number is being specified in
				var format:Int = 0;
				//- CharCodes of Letters A-F in both upper and lower case
				var ltrCodes:Array<Int> = [97, 98, 99, 100, 101, 102, 65,66, 67, 68, 69, 70];

				while (true) attemptByte(this, {
					//- if [bit] is a standard number
					if (bit.isNumeric()) {
						num_str += bit;
					}
					
					//- if [bit] is a period
					else if (bit == '.') {
						//- if the current [format] is "integer" mode, allow this
						if (format == 0) {
							//- and switch [format] to "double" mode
							format = 1;
							num_str += bit;
						} else {
							throw 'Unexpected "."';
						}
					}
					
					//- If [bit] is an "x"
					else if (bit == 'x' || bit == 'X') {
						//- if we've only gathered a 0 so far
						if (num_str == '0' && format == 0) {
							//- switch to hexidecimal mode
							format = 2;
							num_str += bit;
						} else {
							throw 'Unexpected "x"';
						}
					}
					
					/**
					  * If we're in hexidecimal mode, and [bit] is any of letters A-F,
					  * in upper or lower case
					  */
					else if (format == 2 && ltrCodes.has( bit )) {
						num_str += (bit+'').toUpperCase();
					}
					
					//- If [bit] is anything else
					else {
						//- push it back onto the stack
						source.back( bit );

						//- end the loop
						break;
					}
				}, 
				/* If [bit] couldn't be retrieved */
				{
					//- If the last character collected was either '.' or 'x'
					if (num_str.endsWith('.') || num_str.endsWith('x') || num_str.endsWith('X')) {
						throw 'Unexpected end of input';
					}

					else {
						//- Get the numeric value of [num_str]
						var num:Float = (switch(format) {
							case 0, 1: (Std.parseFloat(num_str));
							case 2: (Std.parseInt(num_str) + 0.0);
							default:
								throw 'Unknown numeric-declaration format $format';
						});
						var tk:Token = Token.TNumber( num );
						return tk;
					}
				});

				//- Get the numeric value of [num_str]
				var num:Float = (switch(format) {
					case 0, 1: (Std.parseFloat(num_str));
					case 2: (Std.parseInt(num_str) + 0.0);
					default:
						throw 'Unknown numeric-declaration format $format';
				});
				var tk:Token = Token.TNumber( num );
				return tk;
			}
			
			/**
			  * == [OPERATORS] ==
			  */
			else if (isOperator( c )) {
				var op_str:String = (c + '');

				while (true) attemptByte(this, {
					if (isOperator(bit)) {
						op_str += bit;
					}
					else {
						source.back(bit);

						break;
					}
				},
				{
					break;
				});
				
				var tk:Token = Token.TOperator( op_str );
				return tk;
			}

			/**
			  * Structures wrapped in Box-Brackets
			  */
			else if (c == '[') {
				//- All text between the brackets
				var content:String = this.group(('['.code), (']'.code));
				var nodes:Array<Token> = lex( content );
				log( nodes );

				switch (nodes) {
					case [Token.TNumber(n)]:
						return Token.TArrayAccess(n);

					case [Token.TNumber(start), Token.TColon, Token.TNumber(end)]:
						return Token.TRangeAccess(start, end);

					default:
						push(Token.TOBracket);
						for (node in nodes) {
							push( node );
						}
						push(Token.TCBracket);
						return null;
				}
			}

			/**
			  * == [GROUPS AND TUPLES] ==
			  */
			else if (c == '(') {
				trace( "Encountering either a group or a tuple!" );

				var content:String = this.group(('('.code), (')'.code));
				var nodes:Array<Token> = lex( content );
				log( nodes );
				
				//- The new list of Tokens
				var subtree:Array<Token> = new Array();

				//- The tuple, if this is one
				var tup:Array<Array<Token>> = new Array();

				//- The 'current' index in [nodes]
				var i:Int = 0;

				//- Either 'group mode'(0) or 'tuple mode'(1)
				var mode:Int = 0;

				//- The 'last' token we encountered
				var last:Null<Token> = null;

				while ( true ) {
					//- Get the 'next' token
					var t:Null<Token> = nodes[i];
					
					//- If there isn't one
					if (t == null) {
						//- if [last] is defined
						if (last != null) {
							subtree.push( last );
						}

						//- if there's still a token in the 'buffer'
						if (subtree.length > 0) {
							//- Determine what to do with it
							switch (mode) {
								//- Group Mode
								case 0:
									//- Do nothing
									null;

								//- Tuple Mode
								case 1:
									//- add the buffer to [tup]
									tup.push( subtree );
									
									//- reset the buffer
									subtree = new Array();

								//- Anything Else
								default:
									throw 'WTFError: Got a "mode" of $mode! How??';
							}
						}

						//- end this loop
						break;
					}
					
					//- If we got one, determine what to do with it
					switch ( t ) {
						//- if it's a comma
						case Token.TComma:

							//- Set the current mode to "tuple mode"
							mode = 1;

							//- if [last] has been defined
							if (last != null) {
								
								//- add it to the buffer
								subtree.push( last );
								
								//- nullify it
								last = null;
							}

							//- If there's at least one token in the buffer
							if (subtree.length > 0) {
								//- Add the buffer to [tup]
								tup.push( subtree );

								//- Reset the buffer
								subtree = new Array();
							}

							//- If there was nothing in the buffer
							else {
								
								//- This is incorrect syntax
								throw 'SyntaxError: Unexpected ","!';
							}

							//- and it's preceded by another token
							//if (last != null) {
							//	mode = 1;
							//	subtree.push( last );
							//	last = null;

							//	tup.push( subtree );
							//	subtree = new Array();
							//}

						//- if it's anything else
						default:
							//- if we're in "group mode"
							if (mode == 0) {
								//- if this is the first token
								if (i == 0) {
									last = t;
								} 
								
								//- If it is not
								else {
									//- if there is a 'last' token, add it to the [subtree] first
									if (last != null) {
										subtree.push( last );
										last = null;
									}

									subtree.push( t );
								}
							}
							
							//- if we're in "tuple mode"
							else if (mode == 1) {
								
								subtree.push( t );
							}

					}

					i++;
				}

				//- now, we have our [subtree] and we've determined the [mode]

				//- firstly, if there were no tokens in the subtree
				if (subtree.length == 0 && tup.length == 0) {
					return null;
				}

				//- Otherwise
				else {
					switch (mode) {
						//- Group Mode
						case 0:
							//- Declare our token, which we will be returning
							var tk:Token = Token.TGroup( subtree );

							//- But, before we return it, check to see if the last Token was an Identifier
							var last:Null<Token> = pop();
							
							//- If this isn't the first token of the tree
							if (last != null) {
								//- Determine what to do with the last Token
								switch( last ) {
									//- If it was an identifier
									case Token.TIdent( id ):
										//- Then we shall assume this to be a function-call
										tk = Token.TCall(id, [subtree]);

									//- If it was anything else
									default:
										null;
								}
							}

							return tk;


						//- Tuple Mode
						case 1:
							//- Declare our Token, which we will be returning
							var tk:Token = Token.TTuple( tup );

							//- But, before we return it, check to see if the last Token was an Identifier
							var last:Null<Token> = pop();
							
							//- If this isn't the first token of the tree
							if (last != null) {
								//- Determine what to do with the last Token
								switch( last ) {
									//- If it was an identifier
									case Token.TIdent( id ):
										//- Then we shall assume this to be a function-call
										tk = Token.TCall(id, tup);

									//- If it was anything else
									default:
										null;
								}
							}

							return tk;

						//- Any other bullshit
						default:
							throw 'Error: Unrecognized mode $mode in parenthetical group parsing!';
					}
				}
			}

			/**
			  * Hashtags
			  */
			else if (c == '#') {
				return Token.THash;
			}

			/**
			  * Colons
			  */
			else if (c == ':') {
				return Token.TColon;
			}

			/**
			  * Question-Mark
			  */
			else if (c == '?') {
				return Token.TQuestion;
			}

			/**
			  * Commas
			  */
			else if (c == ',') {
				return Token.TComma;
			}

			/**
			  * @ Symbol
			  */
			else if (c == '@') {
				try {
					//- get the next token
					var nxt = token();
					//- if there was a next token
					if (nxt != null) {
						//- determine what to do with it
						switch (nxt) {
							//- Identifier, Number
							case Token.TIdent(_), Token.TNumber(_):
								return Token.TRefence( nxt );
							
							default:
								throw 'SyntaxError: Expected identifier or number, got $nxt!';
						}
					}
				} catch (err : String) {
					throw 'SyntaxError: Expected identifier, got EOL';
				}	
			}
		} 
		
		//- If that fails
		catch (err : String) {
			//- if it failed because we've reached the end of our input
			if (( err+'' ) == 'Eof') {
				//- Declare this tokenization complete
				throw (COMPLETION_ERROR);
			} 
			//- if it failed for any other reason
			else {
				//- rethrow the error
				throw err;
			}
		}

		return null;
	}

	/**
	  * Primary entry-point to the actual lexing process
	  */
	public function lexString(s : String):Array<Token> {
		//- Initialize the state of [this] Lexer
		source = ByteInput.fromString(s);
		tree = new Array();
		
		//- Actually Perform the Analysis
		while (true) {
			try {
				var tk = token();
				log( tk );
				if (tk != null) {
					tree.push( tk );
				}
			} catch (err : String) {
				log( err );
				if (err == COMPLETION_ERROR) {
					break;
				} else {
					throw err;
				}
			}
		}

		return tree;
	}
	
	/**
	  * Determines whether the given Byte [c] is an operator
	  */
	public function isOperator(c : Byte):Bool {
		return ([
			
			'+', '-', '*', '/',
			'=', '!', '~', '<', '>',
			'|'

		].has(c.toString()));
	}

	/**
	  * Gets and returns the 'next' Byte in our source
	  */
	public inline function byte():Null<Byte> {
		return (source.next());
	}

	/**
	  * Push a Token onto [tree]
	  */
	private inline function push(tk : Token):Void {
		tree.push( tk );
	}

	/**
	  * Pop the last-lexed token off of the Stack
	  */
	private inline function pop():Null<Token> {
		return (tree.pop());
	}

	/**
	  * Finds the entirety of the token-group specified by [group-data]
	  * > this function makes the assumption that the first [opener] has already been found
	  * [group-data]:
	    + [opener] - beginning grouping-symbol
	    + [closer] - ending grouping-symbol
	    + [escape] - optional symbol which nullifies [opener] or [closer] when preceding them
	  */
	private function group(opener:Byte, closer:Byte, ?escape:Byte):String {
		var found:String = '';
		var state:Int = 1;

		while (state > 0) attemptByte(this, {
			if (bit == opener) {
				state++;
			}
			if (bit == closer) {
				state--;
			}
			if (state > 0) {
				found += bit;
			}
		}, {
			if (state > 0) {
				throw 'Unexpected end of input';
			} else {
				break;
			}
		});

		return found;
	}

	/**
	  * Macro method to attempt to retrieve the next Byte,
	  * allowing declaration of what to refer to that Byte as,
	  * what to do with the Byte if successful,
	  * and what to do on failure
	  */
	private static macro function attemptByte(self:Expr, useByteForStuff:Expr, handleFailure:Expr):Expr {
		return macro {
			try {
				var bit = byte();

				$useByteForStuff;
			} catch (err : String) {
				
				if (( err+'' ) == 'Eof') {
					
					$handleFailure;
				} else {
					
					throw err;
				}
			}
		};
	}
	
/* === Class Methods === */

	/**
	  * Class-Level Method to:
	    - create a new Lexer
	    - tokenize a String
	    - return the node-tree
	  */
	public static inline function lex(s : String):Array<Token> {
		return (new Lexer().lexString( s ));
	}

	/**
	  * Alias to `trace`
	  */
	public static inline function log(x : Dynamic):Void {
		null;
	}

	private static inline var COMPLETION_ERROR:String = '::-EOI-::';
}
