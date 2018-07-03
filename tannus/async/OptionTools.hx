package tannus.async;

import tannus.ds.Delta;
import tannus.io.Signal;
import tannus.io.Signal2;

import tannus.async.promises.*;
import tannus.async.Promise;

import haxe.ds.Option;
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

class OptionTools {
    public static inline function isNone<T>(o: Option<T>):Bool return o.match(None);
    public static inline function isSome<T>(o: Option<T>):Bool return o.match(Some(_));
    public static inline function getValue<T>(o: Option<T>):Null<T> {
        return switch o {
            case null, None: null;
            case Some(v): v;
        };
    }
    public static inline function ifSome<T>(o:Option<T>, f:T->Void) {
        switch o {
            case Some(v): f(v);
            case _:
        }
    }
    public static inline function map<TIn,TOut>(o:Option<TIn>, f:TIn->TOut):Option<TOut> {
        return switch o {
            case null, None: None;
            case Some(x): Some(f(x));
        };
    }
}
