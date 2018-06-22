package tannus.async;

import tannus.ds.Delta;
import tannus.io.Signal;
import tannus.io.Signal2;

import tannus.async.promises.*;
import tannus.async.Promise;

import haxe.extern.EitherType as Either;
import haxe.macro.Expr;
import haxe.macro.Context;

import Slambda.fn;
import Reflect.deleteField;

using Slambda;
using tannus.ds.ArrayTools;
using tannus.FunctionTools;

using haxe.macro.ExprTools;
using haxe.macro.TypeTools;
using haxe.macro.ComplexTypeTools;
using tannus.macro.MacroTools;

class PromiseTools {
    public static function ofResult<TIn, TOut, Prom:Promise<TIn>>(prom:Prom, ?map:TIn->TOut):Promise<Result<TOut, Dynamic>> {
        if (map == null) untyped {
            map = FunctionTools.identity;
        }

        return prom.transform(map).derive(function(src, yes, no) {
            yes = yes.once();
            src.then(
                function(o: TOut) {
                    yes(Result.ResSuccess( o ));
                },
                function(err: Dynamic) {
                    yes(Result.ResFailure( err ));
                }
            );
        });
    }

    @:native('_void_')
    public static function void<T, Prom:Promise<T>>(prom: Prom):VoidPromise {
        return new VoidPromise(function(y, n) {
            prom.then((x->y()), (x->n(x)));
        });
    }
}

class PromiseResTools {
    public static function isPromise<T>(res : PromiseResolution<T>):Bool {
        return (res is Promise<Dynamic>);
    }
    public static function asPromise<T>(res : PromiseResolution<T>):Promise<T> return cast res;
    public static function asValue<T>(res : PromiseResolution<T>):T return untyped res;
}
