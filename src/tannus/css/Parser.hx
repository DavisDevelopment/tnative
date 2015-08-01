package tannus.css;

import tannus.io.Ptr;
import tannus.ds.Dict;
import tannus.ds.Maybe;

import tannus.css.Token;
import tannus.css.Expr;
import tannus.css.Value;
import tannus.css.Property in Prop;
import tannus.css.vals.Lexer.parseString in parseValues;
import tannus.css.StyleSheet;
import tannus.css.Rule;

using StringTools;
using Lambda;
using tannus.ds.ArrayTools;
using tannus.ds.StringUtils;

class Parser {
	/* Constructor Function */
	public function new():Void {
		reset();
	}

/* === Instance Methods === */

	/**
	  * Parse the provided Token-Tree
	  */
	public function parse(tks : Array<Token>):Array<Expr> {
		reset();
		tokens = tks;

		while (true) {
			try {
				var e:Null<Expr> = parseToken();
				if (e != null) {
					add( e );
				}
			}
			catch (err : Err) {
				switch ( err ) {
					case Eoi:
						break;

					case Unexpected( tk ):
						var e:String = 'CSSError: Unexpected $tk!';
						trace( e );
						throw e;
				}
			}
		}

		return tree;
	}

	/**
	  * Parse the next Token in the Stack
	  */
	private function parseToken():Null<Expr> {
		var t = token();
		switch ( t ) {
			/* End of Input */
			case TEof:
				eof();

			/* CSS Selector */
			case TSel( s ):
				var next:Token = token();
				switch (next) {
					/* Another Selector */
					case TSel( sub ):
						var r = parseToken();
						if (r == null) {
							throw 'CSSError: Expected Selector, got EOI!';
						}
						switch (r) {
							case ERule(ss, content):
								return ERule('$ss $sub', content);

							default:
								var e:String = 'CSSError: Unexpected $r!';
								throw e;
						}

					/* Block */
					case TBlock( toks ):
						var content:Array<Expr> = new Array();
						for (bt in toks) {
							switch (bt) {
								case TProp(name, sval):
									var eprop = EProp(name, parseValues(sval));
									content.push( eprop );

								default:
									unex( bt );
							}
						}
						return ERule(s, content);

					/* Anything Else */
					default:
						unex( next );
				}

			/* Variable Declaration */
			case TVar(name, sval):
				variables.set(name, parseValues(sval)[0]);
				return null;

			/* Anything Else */
			default:
				unex( t );
		}
	}

	/**
	  * Reset [this] Parser to it's default state
	  */
	private inline function reset():Void {
		tokens = new Array();
		tree = new Array();
		variables = new Dict();
	}

	/**
	  * Get the next Token in the tree
	  */
	private inline function token():Token {
		return (tokens.shift());
	}

	/**
	  * Place a Token back onto the Stack
	  */
	private inline function undo(t : Token):Void {
		tokens.unshift( t );
	}

	/**
	  * Add an Expr onto the Stack
	  */
	private inline function add(e : Expr):Void {
		tree.push( e );
	}

/* === Instance Fields === */

	private var tokens : Array<Token>;
	private var tree : Array<Expr>;
	private var variables : Dict<String, Value>;

/* === Static Methods === */

	/**
	  * Throw an 'Unexpected [t]' Error
	  */
	private static inline function unex(t : Token):Void {
		throw Err.Unexpected( t );
	}

	/**
	  * Throw an EOI Error
	  */
	private static inline function eof():Void {
		throw Err.Eoi;
	}
}

private enum Err {
	Eoi;
	Unexpected(tk : Token);
}
