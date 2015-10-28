package tannus.ds;

import haxe.Constraints.Function;

@:callable
abstract Method<T> (Array<Dynamic> -> T) {
	public inline function new(func:Function, ?ctx:Dynamic):Void {
		this = Reflect.callMethod.bind(ctx, func, _);
	}

	/**
	  * Call The Function Normally
	  */
	public var call(get, never):Dynamic;
	private inline function get_call():Dynamic {
		return Reflect.makeVarArgs(this);
	}

	@:from
	public static inline function fromFunction<T>(f : Function):Method<T> {
		return new Method(f);
	}
}
