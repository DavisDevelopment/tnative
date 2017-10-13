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

using haxe.macro.ExprTools;
using haxe.macro.TypeTools;
using haxe.macro.ComplexTypeTools;
using tannus.macro.MacroTools;

class PromiseTools {
    public static function isPromise<T>(res : PromiseResolution<T>):Bool {
        return (res is Promise<Dynamic>);
    }
    public static function asPromise<T>(res : PromiseResolution<T>):Promise<T> return cast res;
    public static function asValue<T>(res : PromiseResolution<T>):T return untyped res;
}
