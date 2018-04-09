package tannus.async;

import tannus.ds.Stack;
import tannus.async.VoidCb;

import haxe.Constraints.Function;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

using Lambda;
using Slambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;

using haxe.macro.ExprTools;
using haxe.macro.TypeTools;
using tannus.macro.MacroTools;

/*
   pman.async.VoidAsyncs
  ---
   mixin class of helper functions regarding VoidAsync functions
*/
class VoidAsyncs {
    /**
      * execute every item in [i] as a series, each one running only after the previous one has finished
      */
    public static function series(i:Iterable<VoidAsync>, done:VoidCb):Void {
        var s = new Stack(i.array());
        var f : VoidAsync;
        function next():Void {
            if ( s.empty ) {
                done();
            }
            else {
                f = s.pop();
                f(function(?error) {
                    if (error != null)
                        done( error );
                    else
                        next();
                });
            }
        }
        next();
    }

    /**
      * invoke all items in [i] simultaneously, and invoke [done] when all have completed
      */
    public static function callEach(i:Iterable<VoidAsync>, done:VoidCb):Void {
        var n = [0, 0];
        function handle(?error:Dynamic) {
            if (error != null) {
                done( error );
            }
            else {
                n[1] += 1;
                if (n[0] == n[1]) {
                    done();
                }
            }
        }
        for (va in i) {
            n[0] += 1;
            va( handle );
        }
    }
    public static inline function parallel(i:Iterable<VoidAsync>, done:VoidCb):Void callEach(i, done);

    /**
      * forward error to given VoidCb
      */
    public static macro function forward(callback:ExprOf<VoidCb>, error:ExprOf<Null<Dynamic>>) {
        return macro if ($error != null) return $callback( $error );
    }

    public static macro function attemptWith(callback:ExprOf<VoidCb>, action:Expr) {
        action = action.replace(macro _cb_, callback);
        return macro {
            try {
                $action;
            }
            catch (error: Dynamic) {
                $callback( error );
            }
        };
    }

    public static macro function sub(callback:ExprOf<VoidCb>, action:Expr):ExprOf<VoidCb> {
        action = action.replace(macro _cb_, callback);
        var efunc:ExprOf<VoidCb> = (macro function(?error: Dynamic) {
            if (error != null) {
                return $callback( error );
            }
            else {
                try {
                    $action;
                }
                catch (error: Dynamic) {
                    return $callback( error );
                }
            }
        });
        return efunc;
    }

    public static function toPromise(f: VoidCb->Void):VoidPromise {
        return new VoidAsync( f ).promise();
    }

    public static function toAsync(promise:VoidPromise, ?callback:VoidCb):VoidPromise {
        if (callback != null) {
            promise.then(callback.void(), callback.raise());
        }
        return promise;
    }

    /**
      * apply [params] to [f] with [callback] as the last argument
      */
    private static function applyAsync<F:Function, T>(f:F, params:Array<Dynamic>, callback:Cb<T>):Void {
        Reflect.callMethod(null, untyped f, params.concat([callback]));
    }
    private static function doApplyAsync<F:Function, T>(f:F, params:Array<Dynamic>):Async<T> {
        return (callback -> applyAsync(f, params, callback));
    }

    public static function applyEach<Func:Function, T>(funcs:Array<Func>, params:Array<Dynamic>, callback:Cb<Array<T>>):Void {
        var results:Array<T> = new Array();
        funcs.map(f -> doApplyAsync(f, params)).map(function(f: Async<T>) {
            return (function(next: VoidCb) {
                f(function(?error, ?value) {
                    if (error != null) {
                        return next( error );
                    }
                    else {
                        results.push( value );
                        next();
                    }
                });
            });
        });
    }
}

/*
class F0VoidAsyncTools {
    public static function toAsync(f:(Void->Void)->Void):VoidAsync {
        return (function(done: VoidCb) {
            try {
                f(function() {
                    done();
                });
            }
            catch (error: Dynamic) {
                done( error );
            }
        });
    }

    public static function toCallback(f:Void->Void):VoidCb {
        return (function(?error) {
            if (error != null) {
                throw error;
            }
            else {
                f();
            }
        });
    }
}
*/

class VoidVoidTools {
    /**
      * asyncify a synchronous function
      */
    public static function toAsync(f: Void->Void):VoidAsync {
        return (function(_: VoidCb) {
            var err:Null<Dynamic> = null;
            try {
                f();
            }
            catch (e: Dynamic) {
                err = e;
            }
            return _( err );
        });
    }
}
