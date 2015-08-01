package tannus.css;

import tannus.css.StyleSheet;
import tannus.css.Rule;
import tannus.css.Property;
import tannus.css.Parser;
import tannus.css.Expr;
import tannus.css.Lexer;
import tannus.css.Value;

import tannus.io.Ptr;
import tannus.io.RegEx;
import tannus.io.ByteArray;
import tannus.ds.Dict;

import Std.*;

using Lambda;
using tannus.ds.ArrayTools;
using tannus.css.vals.ValueTools;

@:access(tannus.css.Parser)
class Compiler {
	/* Constructor Function */
	public function new():Void {
		reset();
	}

/* === Instance Methods === */

	/**
	  * Reset [this] to it's default State
	  */
	private inline function reset():Void {
		ast = new Array();
		sheet = new StyleSheet();
		variables = new Dict();
		functions = new Dict();
		makeFunctions();
	}

	/**
	  * Compile the given code
	  */
	public function compile(code : String):StyleSheet {
		reset();
		var tokens = (new Lexer().lex(ByteArray.fromString(code)));
		var parser = new Parser();
		ast = (parser.parse( tokens ));
		variables = parser.variables;

		for (e in ast) {
			compileExpr( e );
		}

		return sheet;
	}

	/**
	  * Compile a single Expression
	  */
	public function compileExpr(e : Expr):Void {
		switch ( e ) {
			case ERule(selector, content):
				var rule:Rule = sheet.rule(selector);
				trace(variables.toObject());
				for (se in content) {
					switch (se) {
						case EProp(pname, pvals):
							var svals:Array<String> = new Array();
							pvals.each(val, svals.push(val.toString(variables, functions)));
							rule.set(pname, svals.join(' '));


						default:
							throw 'CSSError: Unexpected $se!';
					}
				}

			default:
				throw 'CSSError: Unexpected $e!';
		}
	}

	/**
	  * Declare all functions
	  */
	private function makeFunctions():Void {
		functions['rgb'] = function(args : Array<Value>):Value {
			switch (args) {
				case [VNumber(red, _), VNumber(green, _), VNumber(blue, _)]:
					return VColor(new tannus.graphics.Color(int(red), int(green), int(blue)));

				default:
					throw 'CSSError: Invalid arguments to "rgb"';
					return VString('');
			}
		};
	}

/* === Instance Fields === */

	/* The AST we're working with */
	private var ast : Array<Expr>;

	/* The StyleSheet we're working with */
	private var sheet : StyleSheet;

	/* The variables declared in the stylesheet */
	public var variables : Dict<String, Value>;
	public var functions : Dict<String, ValueFunction>;
}

private typedef ValueFunction = Array<Value> -> Value;
