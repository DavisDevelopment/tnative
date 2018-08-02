package tannus.stream;

import tannus.ds.dict.DictKey;
import tannus.ds.Pair;
import tannus.ds.Delta;
import tannus.io.Signal;
import tannus.io.VoidSignal;

import tannus.async.Future;
import tannus.async.Promise;
import tannus.async.Result;
import tannus.async.AsyncError;
import tannus.async.Broker;

import haxe.ds.Option;
import haxe.ds.Either;
import haxe.Constraints.Function;
import haxe.extern.EitherType;
import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.Context;

import Slambda.fn;
import Reflect.deleteField;

using Slambda;
using tannus.ds.ArrayTools;
using tannus.ds.IteratorTools;
using tannus.FunctionTools;
using tannus.async.Result;
using tannus.async.OptionTools;
using tannus.async.Asyncs;

using haxe.macro.ExprTools; 
using haxe.macro.TypeTools;
using haxe.macro.ComplexTypeTools;
using tannus.macro.MacroTools;

class Tools {}

class FutureTools {
    public static function resPromise<Item, Error>(future:Future<Item, Error>):Promise<Result<Item, Error>> {
        return new Promise<Result<Item, Error>>(function(accept, _) {
            future.then(function(outcome: Result<Item, Error>) {
                accept( outcome );
            });
        });
    }

    public static function map<TIn, TOut, TErr>(future:Future<TIn,TErr>, f:TIn->TOut):Future<TOut, TErr> {
        return new Future<TOut, TErr>(function(out) {
            future.then(function(outcome) {
                switch outcome {
                    case ResSuccess(value):
                        return out.yield(f(value));

                    case ResFailure(error):
                        return out.raise(error);
                }
            });
        });
    }
}

class PromiseTools {
    public static function future<Item, Error>(promise: Promise<Result<Item, Error>>):Future<Item, Error> {
        return new Future<Item, Error>(function(future) {
            promise.then(function(outcome: Result<Item, Error>) {
                switch outcome {
                    case ResSuccess(item):
                        future.yield( item );

                    case ResFailure(error):
                        future.raise( error );
                }
            });
        });
    }
}
