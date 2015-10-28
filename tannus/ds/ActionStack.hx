package tannus.ds;

import tannus.io.Signal;
import tannus.io.Pointer;
import tannus.ds.Maybe;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;

using haxe.macro.ExprTools;

@:forward
abstract ActionStack (Array<Void -> Void>) {
	/* Constructor Function */
	public inline function new():Void {
		this = new Array();
	}

/* === Instance Methods === */

	/**
	  * Add an Action onto [this] Stack
	  */
	public macro function append(self:ExprOf<ActionStack>, action:Expr) {
		return macro $self.push(function() {
			$action;
		});
	}

	/**
	  * Invoke [this] ActionStack
	  */
	public inline function call():Void {
		for (action in this) {
			action();
		}
	}

	/**
	  * Create and return a clone of [this] ActionStack
	  */
	public inline function clone():ActionStack {
		return cast this.copy();
	}
}

@:forward
abstract ParametricStack<T> (Array<T -> Void>) {
	/* Constructor Function */
	public inline function new():Void {
		this = new Array();
	}

/* === Instance Methods === */

	/**
	  * Add an Action onto [this] Stack
	  */
	public macro function append<T>(self:ExprOf<ParametricStack<T>>, action:Expr) {
		function mapper(e : Expr) {
			switch (e.expr) {
				case ExprDef.EConst(CIdent('self')):
					return {
						'expr': EConst(CIdent('__context')),
						'pos': Context.currentPos()
					};

				default:
					return e.map(mapper);
			}
		}
		action = action.map(mapper);
		return macro $self.push(function(__context) {
			$action;
		});
	}

	/**
	  * Call [this] Stack
	  */
	public inline function call(context : T):Void {
		for (a in this)
			a( context );
	}
}
