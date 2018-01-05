package tannus.ds;

import haxe.extern.EitherType;

using tannus.FunctionTools;

abstract Thunk<T> (EitherType<Void->T, T>) from EitherType<Void->T, T> to EitherType<Void->T, T> {
    public inline function new(x: EitherType<Void->T, T>) {
        this = x;
    }

    @:to
    public function resolve():T {
        if (Reflect.isFunction( this ))
             return untyped this();
        else return untyped this;
    }
}
