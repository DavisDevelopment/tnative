package tannus.nore;

import tannus.ds.Stack;

import tannus.nore.Token;
import tannus.nore.Check;
import tannus.nore.Value;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;
using tannus.nore.ValueTools;

class Parser {
	/* Constructor Function */
	public function new():Void {
		reset();
	}

/* === Instance Methods === */

	/**
	  * parse the given Token Array
	  */
	public function parse(tokenList : Array<Token>):Array<Check> {
		reset();
		tokens = new Stack(tokenList);

		while ( !end ) {
			tree.push(nextCheck());
		}

		return tree;
	}

	/**
	  * Parse the next Check, and return it
	  */
	private function nextCheck():Check {
		var t:Token = token();
		switch ( t ) {
			/* == Type Check == */
			case TConst(CIdent( type )):
				return TypeCheck( type );

			/* == Loose Type Check == */
			case TApprox:
				t = token();
				switch ( t ) {
					case TConst(CIdent( type )):
						return LooseTypeCheck( type );

					default:
						throw 'SyntaxError: Unexpected $t!';
				}

			/* == Shorthand Type Check == */
			case TDoubleDot:
				t = token();
				switch ( t ) {
					case TConst(CIdent( type )):
						return ShortTypeCheck( type );

					default:
						throw 'SyntaxError: Unexpected $t!';
				}

			/* == Field Checks == */
			case TBrackets( group ):
				switch ( group ) {
					/* == Existential Check == */
					case [TConst(CIdent( name )|CString(name, _))]:
						return FieldExistsCheck( name );

					/* == Value Block Check == */
					case [TConst(CIdent(name)|CString(name, _)), TOperator('=>'), TBoxBrackets(sub(_) => checks)]:
						return FieldValueBlockCheck(name, checks);

					/* == Strict Type Check == */
					case [TConst(CIdent(name)|CString(name,_)), TOperator('is'), TConst(CIdent(type))]:
						return FieldValueTypeCheck(name, type, false);

					/* == Loose Type Check == */
					case [TConst(CIdent(name)|CString(name, _)), TOperator('is'), TApprox, TConst(CIdent(type))]:
						return FieldValueTypeCheck(name, type, true);

					/* == Nested Check == */
					case [TConst(CIdent('this')), TOperator(op), valueToken]:
						return NestedCheck(op, valueToken.toValue());

					/* == Value Check == */
					case [TConst(CIdent(name)|CString(name, _)), TOperator(op), valueToken]:
						return FieldValueCheck(op, name, valueToken.toValue());

					/* == Anything Else == */
					default:
						throw 'SyntaxError: $group is not a valid field-check!';
				}

			/* == Group Checks == */
			case TGroup( group ), TBoxBrackets( group ):
				var subChecks:Array<Check> = sub( group );
				return GroupCheck( subChecks );

			/* == Helper Checks == */
			case THelper(name, argTokens):
				var args:Array<Value> = [for (t in argTokens) t.toValue()];
				return HelperCheck(name, args);

			/* == OR Checks == */
			case TOr:
				var left = last();
				var right = nextCheck();
				switch ([left, right]) {
					case [null, r]:
						throw 'SyntaxError: Unexpected "|"!';

					case [l, null]:
						throw 'SyntaxError: Unexpected end of input!';

					case [l, r]:
						return EitherCheck(left, right);
				}

			/* == NOT Checks == */
			case TNot:
				var check = nextCheck();
				if (check != null) {
					return InvertedCheck( check );
				}
				else {
					throw 'SyntaxError: Unexpected end of input!';
				}

			/* == IF Check == */
			case TIf(ttest, tthen, telse):
				var toks:Array<Token> = [ttest, tthen];
				if (telse != null)
					toks.push( telse );
				var chl = sub( toks );
				return Type.createEnum(Check, 'TernaryCheck', chl);

			/* == Anything Else == */
			default:
				throw 'SyntaxError: Unexpected $t!';
		}
	}

	/**
	  * Restore [this] to it's default state
	  */
	private function reset():Void {
		tokens = new Stack();
		tree = new Array();
	}

	/**
	  * Get the next token
	  */
	private inline function token():Token {
		return tokens.pop();
	}

	/**
	  * Get the last-parsed Check
	  */
	private inline function last():Null<Check> {
		return tree.pop();
	}

	/**
	  * Get the current state of [this] Parser
	  */
	private function save():State {
		return {
			'tokens' : tokens.copy(),
			'tree' : tree.copy()
		};
	}

	/**
	  * Restore to a previous State
	  */
	private function restore(s : State):Void {
		tokens = s.tokens;
		tree = s.tree;
	}

	/**
	  * Parse a sub-tree
	  */
	private function sub(toks : Array<Token>):Array<Check> {
		var child = new Parser();
		return child.parse( toks );
	}

/* === Computed Instance Fields === */

	/* whether we've reached the end of our input */
	private var end(get, never):Bool;
	private inline function get_end():Bool return tokens.empty;

/* === Instance Fields === */

	private var tokens : Stack<Token>;
	private var tree : Array<Check>;

/* === Static Methods === */

	/**
	  * shorthand to parse the given Token tree
	  */
	public static inline function parseTokens(tree : Array<Token>):Array<Check> {
		return (new Parser().parse( tree ));
	}

	/**
	  * shorthand to parse the given String
	  */
	public static inline function parseString(s : String):Array<Check> {
		return parseTokens(Lexer.lexString( s ));
	}
}

private typedef State = {
	var tokens : Stack<Token>;
	var tree : Array<Check>;
};
