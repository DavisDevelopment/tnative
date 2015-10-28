package tannus.css;

import tannus.css.Token;
import tannus.css.Expr;

import tannus.ds.Stack;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;

class Parser {
	/* Constructor Function */
	public function new():Void {
		tokens = new Stack<Token>();
		tree = new Array();
	}

/* === Instance Methods === */

	/**
	  * Parse the given token-tree
	  */
	public function parse(toks : Array<Token>):Array<Expr> {
		tokens = new Stack(toks);
		tree = new Array();

		while (!tokens.empty) {
			var e:Null<Expr> = expr();
			if (e == null)
				break;
			else
				tree.push( e );
		}

		return tree;
	}

	/**
	  * Get the next Expression
	  */
	private function expr():Null<Expr> {
		if (tokens.empty) {
			return null;
		}
		else {
			var t = token();
			switch ( t ) {
				/* == Identifiers === */
				// case TIdent( id ):

				/* == Anything Else == */
				default:
					unexpected( t );
			}
		}
	}

/* === Utility Methods === */

	/**
	  * Peek at the next Token in the list
	  */
	private inline function peek():Token return tokens.peek();

	/**
	  * Get the next Token in the list
	  */
	private inline function token():Token return tokens.pop();

	/**
	  * Get the current State of [this] Parser
	  */
	private function save():State {
		return {
			'tokens': tokens.copy(),
			'tree'  : tree.copy()
		};
	}

	/**
	  * Restore to the given State
	  */
	private function restore(s : State):Void {
		tokens = s.tokens;
		tree = s.tree;
	}

	/**
	  * Throw an Error
	  */
	private inline function err(msg : String):Void {
		#if js
			throw new js.Error('CSSError: $msg');
		#else
			throw 'CSSError: $msg';
		#end
	}

	/**
	  * Throw an unexpected Error
	  */
	private inline function unexpected(x : Dynamic):Void {
		err('Unexpected $x');
	}

/* === Instance Fields === */

	private var tokens : Stack<Token>;
	private var tree : Array<Expr>;
}

private typedef State = {
	var tokens : Stack<Token>;
	var tree : Array<Expr>;
};
