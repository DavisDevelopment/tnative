package tannus.async;

import tannus.ds.Delta;
import tannus.io.Signal;
import tannus.io.Signal2;

import tannus.async.promises.*;
import tannus.async.Future;

import haxe.extern.EitherType as Either;
import haxe.macro.Expr;
import haxe.macro.Context;

import Slambda.fn;
import Reflect.deleteField;

using Slambda;
using haxe.macro.ExprTools;
using haxe.macro.TypeTools;
using haxe.macro.ComplexTypeTools;
using tannus.macro.MacroTools;
using tannus.FunctionTools;

class FutureTools {
    public static function promiseFuture<TRes, TErr>(promise: Promise<Dynamic>):Future<TRes, TErr> {
        //TODO
    }

    public static inline function isFuture<TRes, TErr>(res : FutureResolution<TRes, TErr>):Bool {
        return (res is Future<Dynamic, Dynamic>);
    }

    public static inline function isPromise<TRes,TErr>(res: FutureResolution<TRes,TErr>):Bool {
        return (res is Promise<FutureResolution<TRes, TErr>>);
    }

    public static inline function isResult<TRes, TErr>(res: FutureResolution<TRes, TErr>):Bool {
        return (Reflect.isEnumValue(res) && (res is Result<TRes, TErr>));
    }

    public static inline function asFuture<TRes, TErr>(res : FutureResolution<TRes, TErr>):Future<TRes, TErr> return cast res;
    public static inline function asPromise<TRes, TErr>(res: FutureResolution<TRes, TErr>):Promise<FutureResolution<TRes, TErr>> return cast res;
    public static inline function asResult<TRes, TErr>(res: FutureResolution<TRes, TErr>):Result<TRes, TErr> return cast res;
}
