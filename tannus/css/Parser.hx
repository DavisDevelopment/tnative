package tannus.css;

import tannus.css.StyleSheet;
import tannus.css.Rule;
import tannus.css.Value;
import tannus.ds.Stack;

import tannus.css.Token;
import tannus.css.Token.Val;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;
using tannus.ds.MapTools;
using tannus.css.vals.ValueTools;

class Parser {
	/* Constructor Function */
	public function new():Void {
		rule = null;
		macros = new Map();
	}

/* === Instance Methods === */

	/**
	  * parse the given token-tree
	  */
	public function parse(tree : Array<Token>):StyleSheet {
		tokens = tree;
		sheet = new StyleSheet();
		heap = new Stack();
		heap.add(new Scope());
		rule = null;

		while (!tokens.empty()) {
			next();
		}

		return sheet;
	}

	/**
	  * parse the next available Token
	  */
	private function next():Void {
		var tk = token();
		switch ( tk ) {
			/* == variable declaration == */
			case TVar(name, val):
				scope.set(name, val);

			/* == property declaration == */
			case TProp(name, val):
				val = rewrite( val );
				rule.property( name ).setValues( val );

			/* == rule set == */
			case TRule(selector, body):
				var superRule = rule;
				if (rule != null) {
					rule = rule.child( selector );
				}
				else {
					rule = sheet.rule( selector );
				}
				subScope();
				subTree( body );
				superScope();
				rule = superRule;

			case TMixin( name ):
				var mixinRule:Null<Rule> = sheet.getRule( '.$name' );
				if (mixinRule != null) {
					for (p in mixinRule.properties) {
						trace(p.values + '');
						rule.set(p.name, p.value);
					}
				}
				else {
					throw 'MixinError: mixin $name is not defined';
				}
		}
	}

	/**
	  * transform Values before they're used
	  */
	private function rewrite(value : Val):Val {
		var hunks:Array<Val> = new Array();
		for (v in value) {
			switch ( v ) {
				/*
				   variable reference -> stored value
				*/
				case Value.VRef( name ):
					if (scope.exists( name )) {
						hunks.push(rewrite(scope[name]));
					}
					else {
						var err = 'Error: $name is not defined';
						trace( err );
						throw err;
					}

				/*
				   function call -> either values returned by the macro, or a call to the same function, with transformed arguments
				*/
				case Value.VCall(name, args):
					args = rewrite( args );
					if (isMacro( name )) {
						hunks.push(callMacro(name, args));
					}
					else {
						hunks.push([Value.VCall(name, args)]);
					}

				default:
					hunks.push([ v ]);
			}
		}
		return cast hunks.flatten();
	}

	/* do the stuff */
	private function subTree(stree : Array<Token>):Void {
		var _tree = tokens;
		tokens = stree;
		while (!tokens.empty())
			next();
		tokens = _tree;
	}

	/* create a new Scope that extends it's parent */
	private function subScope():Void {
		var sub:Scope = new Scope();
		for (n in scope.keys())
			sub[n] = scope[n];
		heap.add( sub );
	}

	/* destroy the current scope and ascend back to the parent */
	private function superScope():Void {
		heap.pop();
	}

	/* get the next token */
	private inline function token():Token return tokens.shift();

	/**
	  * determine whether any macro with the given name is defined
	  */
	private inline function isMacro(name : String):Bool return macros.exists( name );

	/**
	  * invoke a macro
	  */
	private function callMacro(name:String, args:Val):Val {
		var result = (macros[name]( args ));
		result = rewrite( result );
		return result;
	}

	/**
	  * define a macro
	  */
	public inline function defMacro(name:String, mfunc:ValMacro):Void {
		macros[name] = mfunc;
	}

/* === Computed Instance Fields === */

	private var scope(get, never):Scope;
	private inline function get_scope():Scope return heap.peek();

/* === Instance Fields === */

	private var tokens : Array<Token>;
	private var sheet : StyleSheet;
	private var rule : Null<Rule>;
	private var heap : Stack<Scope>;
	private var macros : Map<String, ValMacro>;

/* === Static Methods === */

	/**
	  * shorthand parsing
	  */
	public static inline function quickParse(tokens : Array<Token>):StyleSheet {
		return (new Parser().parse( tokens ));
	}
}

private typedef Scope = Map<String, Val>;
private typedef ValMacro = Val -> Val;
