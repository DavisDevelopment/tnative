package tannus.ds;

import tannus.io.Getter;

@:forward
abstract Ref<T> (CRef<T>) from CRef<T> {
	/* Constructor Function */
	public inline function new(r : Getter<T>):Void {
		this = new CRef(r);
	}

/* === Instance Methods === */

	/* Cast to underlying type */
	@:to
	public inline function get():T return this.get();

	/* Cast to String */
	@:to
	public inline function toString():String return Std.string(get());

/* === Static Methods === */

	/**
	  * Create a Ref by macro
	  */
	public static macro function create<T>(v : haxe.macro.Expr.ExprOf<T>):haxe.macro.Expr.ExprOf<Ref<T>> {
		return macro new tannus.ds.Ref(tannus.io.Getter.create($v));
	}
}

@:generic
class CRef<T> {
	/* Constructor Function */
	public function new(g : Getter<T>):Void {
		getter = g;
		_value = null;
	}

/* === Instance Methods === */

	/**
	  * Get the value of [this]
	  */
	public function get():T {
		if (_value == null) {
			return (_value = getter.get());
		}
		else {
			return _value;
		}
	}

/* === Instance Fields === */

	private var getter : Getter<T>;
	private var _value : Null<T>;
}
