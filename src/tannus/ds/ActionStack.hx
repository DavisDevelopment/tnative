package tannus.ds;

import tannus.io.Signal;
import tannus.io.Pointer;
import tannus.ds.Maybe;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;

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
