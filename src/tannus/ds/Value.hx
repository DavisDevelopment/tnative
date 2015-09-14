package tannus.ds;

import tannus.io.Getter;

import haxe.macro.Expr;
import haxe.macro.Context;

#if macro
using haxe.macro.ExprTools;
#end

@:forward
abstract Value<T> (CVal<T>) from CVal<T> {
	/* Constructor Function */
	public inline function new(g : Getter<T>):Void {
		this = new CVal(g);
	}

/* === Instance Methods === */

	/* cast to underlying type */
	@:to
	public inline function get():T return this.get();

	/* cast to String */
	@:to
	public inline function toString():String return Std.string(get());

	/* modify [this] Value macroliciously */
	public macro function mod(seff:Expr, action:Expr) {
		return CVal.mod(seff, action);
	}

	/* transform [this] Value */
	/*
	public macro function transform<V>(seff:Expr, action:Expr):ExprOf<Value<V>> {
		function mapper(e : Expr) {
			switch (e.expr) {
				case EConst(CIdent('_')):
					return macro __val;

				default:
					return e.map(mapper);
			}
		}
		action = action.map(mapper);
		return macro ($seff.transform(function(__val) return $action));
	}
	*/

/* === Static Methods === */

	public static macro function create<T>(base : ExprOf<T>):ExprOf<Value<T>> {
		return macro new tannus.ds.Value(tannus.io.Getter.create($base));
	}
}

private class CVal<T> {
	/* Constructor Function */
	public function new(b : Getter<T>):Void {
		base = b;
		mods = new Array();
	}

/* === Instance Methods === */

	/**
	  * Add a modifier to [this] Value
	  */
	public function modify(m : Mod<T>):Void {
		this.mods.push( m );
	}

	/**
	  * Transform [this] value
	  */
	public function transform<V>(t : T->V):CVal<V> {
		return new CVal((new Getter(get)).transform(t));
	}

#if macro
	/**
	  * Add a modifier to [this] Value by macro
	  */
	public static function mod(self:Expr, action:Expr):Expr {
		function mapper(e : Expr):Expr {
			switch (e.expr) {
				case ExprDef.EConst(CIdent('_')):
					return macro __val;

				default:
					return e.map(mapper);
			}
		}
		var act:Expr = action.map( mapper );
		return macro {
			$self.modify(function(__val) {
				return $act;
			});
		};
	}
#end

	/**
	  * Get the modified base-value
	  */
	public function get():T {
		var result:T = base.get();
		for (m in mods)
			result = m(result);
		return result;
	}

/* === Instance Fields === */

	private var base : Getter<T>;
	private var mods : Array<Mod<T>>;
}

private typedef Mod<T> = T -> T;
