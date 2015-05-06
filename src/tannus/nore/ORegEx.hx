package tannus.nore;

import tannus.nore.Lexer;
import tannus.nore.Parser;
import tannus.nore.Check;
import tannus.nore.Compiler;

/**
  * Class collection of utility methods having to do with Object Regular-Expressions
  */
class ORegEx {

	/**
	  * Private Map of the results of the Compile function
	  */
	private static var ast_results : Map<String, Array<Check>> = {new Map();};

	/**
	  * Shorthand function to get a selector-function from a String
	  */
	public static function compile<T> (description : String) {
		//- if [description] is present in [ast_results]
		if (ast_results.exists(description)) {

			var ast = ast_results[description];

			return Compiler.compile( ast );
		}
		
		//- if it is not
		else {
			var ast = Parser.parse(Lexer.lex( description ));

			ast_results[description] = ast;

			return Compiler.compile( ast );
		}
	}
}
