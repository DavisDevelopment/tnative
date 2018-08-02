package tannus.async;

import tannus.ds.Pair;
import tannus.ds.Delta;
import tannus.io.Signal;
import tannus.io.Signal2;

import tannus.async.promises.*;

import haxe.extern.EitherType as EitherType;
import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.Context;

import Slambda.fn;
import Reflect.deleteField;

using Slambda;
using tannus.ds.ArrayTools;
using tannus.async.FutureTools;
using tannus.async.Result;
using tannus.Nil;
using tannus.FunctionTools;

using haxe.macro.ExprTools;
using haxe.macro.TypeTools;
using haxe.macro.ComplexTypeTools;
using tannus.macro.MacroTools;

/*
 ---
*/
class Future <TRes, TErr> {
    /* Constructor Function */
    public function new(exec:FutureExecutor<TRes, TErr>, nomake:Bool=false):Void {
        this.exec = exec;
        //this.statusChange = new Signal();
        this.status = FSUnmade;
        this._dependants = new Array();
        this.signals = {
            resolve : new Signal()
        };

        if (!nomake) {
            _make();
        }
    }

/* === Instance Methods === */
    
    /**
      * handle the settling of [this] Future
      */
    public function then(onResolved: Result<TRes, TErr> -> Void):Future<TRes, TErr> {
        switch (getStatus()) {
            case FSReached( result ):
                onResolved( result );

            case FSPending, FSUnmade:
                signals.resolve.on(x -> onResolved(x));
        }
        return this;
    }

    /**
      * create and return a new Future derived from [this] one
      */
    public function derive<OutRes,OutErr>(extender:Future<TRes, TErr> -> FutureResolutionProvider<OutRes, OutErr> -> Void, ?nomake:Bool):Future<OutRes, OutErr> {
        return new DerivedFuture(extender, this, nomake);
    }

    /**
      * promise a transformation on [this] Future's data
      */
    public function transform<Out, Err>(?mapv:TRes->FutureResolution<Out, Err>, ?mape:TErr->Err, ?nomake:Bool):Future<Out, Err> {
        return cast new TransformedFuture(this, {
            v: mapv,
            e: mape
        });
    }

    /**
      * 'make' [this] Future
      */
    private function _make():Void {
        function provide(res) {
            _resolve( res );
        }

        setStatus( FSPending );
        exec( resolve );
    }

    /**
      * 'make' [this] Future, if not already made
      */
    public function make():Void {
        if (isUnmade()) {
            _make();
        }
    }

    /**
      * resolve [this] Future
      */
    private function _resolve(resolution : FutureResolution<TRes, TErr>):Void {
        _settleResult(resolution, function(o: Result<TRes, TErr>) {
            setStatus(FSReached( o ));
        });
    }

    /**
      * attach [child] Future to [this] one
      */
    @:noCompletion
    public function _attach<A, B>(child : Future<A, B>):Future<A, B> {
        if (!_dependants.has( child )) {
            _dependants.push( child );
        }
        return child;
    }

    public function fork<SubErr>(child:Future<FutureResolution<TRes, SubErr>, SubErr>, translateError:SubErr->TErr):Future<TRes, TErr> {
        child.then(function(out: Result<FutureResolution<TRes, SubErr>, SubErr>) {
            switch ( out ) {
                case ResSuccess( value ):
                    _settleResult(value, function(o: Result<TRes, SubErr>) {
                        switch o {
                            case ResSuccess(v):
                                _resolve(Res.value(v));

                            case ResFailure(e):
                                _resolve(Res.error(translateError(e)));
                        }
                    });

                case ResFailure( error ):
                    _resolve(FutureResolution.error(translateError(error)));
                    //_resolve(Result.Res(translateError(error)));
            }
            //betty
        });
        return this;
    }

    /**
      * assign the value of [status]
      */
    private function setStatus(s : FutureStatus<TRes, TErr>):Future<TRes, TErr> {
        status = s;

        return this;
    }

    /**
      * handle the changing of [status]
      */
    private function statusChanged(d : Delta<FutureStatus<TRes, TErr>>):Void {
        if (d.current != null) {
            var newStatus:FutureStatus<TRes, TErr> = d.current;
            switch ( newStatus ) {
                case FSUnmade:
                    //

                // when [this] Future is made, ensure that its 'children' are also made
                case FSPending:
                    for (child in _dependants) {
                        child.make();
                    }

                case FSReached( result ):
                    signals.resolve.broadcast( result );
                    disposeSignals();
            }
        }
    }

    /**
      * dispose of [signals] once [this] Future has been settled. we don't need them anymore
      */
    private function disposeSignals():Void {
        signals.resolve.clear();
        signals = null;
    }

/* === Info-Getter Instance Methods === */

    /**
      * get the value of [status]
      */
    public inline function getStatus():FutureStatus<TRes, TErr> {
        return status;
    }

    public inline function isUnmade():Bool {
        return (getStatus().equals(FSUnmade));
    }

    public inline function isPending():Bool {
        return (getStatus().equals(FSPending));
    }

    public inline function isSettled():Bool {
        return (getStatus().match(FSReached(_)));
    }

    public inline function isUnsettled():Bool {
        return (getStatus().match(FSUnmade|FSPending));
    }

/* === Casting Methods === */

/* === Computed Instance Fields === */

    private var status(default, set):FutureStatus<TRes, TErr>;
    private function set_status(newStatus : FutureStatus<TRes, TErr>):FutureStatus<TRes, TErr> {
        var old:Null<FutureStatus<TRes, TErr>> = status;
        status = newStatus;
        //statusChange.call(new Delta(status, old));
        statusChanged(new Delta(status, old));
        return status;
    }

/* === Instance Fields === */

    private var exec : FutureExecutor<TRes, TErr>;
    private var signals : Null<{resolve:Signal<Result<TRes, TErr>>}>;
    private var _dependants : Array<Future<Dynamic, Dynamic>>;

/* === Static Methods === */

    public static function async<TRes, TErr>(f: (Result<TRes, TErr>->Void)->Void):Future<TRes, TErr> {
        return new Future<TRes, TErr>(function(out) {
            f(function(result) {
                switch result {
                    case ResSuccess(x):
                        out.yield( x );

                    case ResFailure(e):
                        out.raise(e);
                }
            });
        });
    }

    public static function resolve<TRes, TErr, R:FutureResolution<TRes, TErr>>(res : R):Future<TRes, TErr> {
        return new Future(function(_resolve:FutureResolutionProvider<TRes, TErr>) {
            _resolve(untyped res);
        });
    }

    public static function error<TRes, TErr>(err: TErr):Future<TRes, TErr> {
        return new Future<TRes, TErr>(function(res) {
            res.raise( err );
        });
    }

    public static function pair<A, B, E>(resPair : Pair<FutureResolution<A, E>, FutureResolution<B, E>>):Future<Pair<A, B>, E> {
        return all(untyped [resolve(resPair.left), resolve(resPair.right)]).transform(function(a : Array<Dynamic>) {
            return untyped (new Pair(untyped a[0], untyped a[1]));
        });
    }

    public static function all(proms : Iterable<Future<Dynamic, Dynamic>>):Future<Array<Dynamic>, Dynamic> {
        return new Future(function(out) {
            var values:Array<Dynamic> = [];
            var resolved:Int = 0, total:Int = 0;

            function make_step(i:Int, future:Future<Dynamic, Dynamic>) {
                future.then(function(outcome:Result<Dynamic, Dynamic>) {
                    switch outcome {
                        case ResSuccess(value):
                            values[i] = value;
                            if (resolved == total)
                                out.yield( values );

                        case ResFailure(error):
                            out.raise( error );
                    }
                });
            }

            var index:Int = 0;
            for (prom in proms) {
                total++;
                make_step(index, prom);
                index++;
            }
        });
    }

    public static function _settle<TRes, TErr>(res:FutureResolution<TRes, TErr>, onValue:TRes->Void, ?onError:TErr->Void):Void {
        if (res.isResult()) {
            switch (res.asResult()) {
                case ResSuccess(v):
                    onValue(v);

                case ResFailure(e):
                    if (onError != null)
                        onError(e);
            }
        }
        else {
            var fut = res.asFuture();
            fut.then(function(outcome: Result<TRes, TErr>) {
                switch outcome {
                    case ResSuccess(v):
                        onValue(v);

                    case ResFailure(e):
                        if (onError != null)
                            onError(e);
                }
            });
        }
    }

    public static function _settleResult<T,E>(res:FutureResolution<T,E>, cb:Result<T, E>->Void):Void {
        cb = cb.once();
        _settle(res, fn(cb(ResSuccess(_))), fn(cb(ResFailure(_))));
    }

    /**
      * declarative, less bulky (than using the constructor) macro for creating new promises
      */
    public static macro function create<TRes, TErr>(e:Expr, rest:Array<Expr>):ExprOf<Future<TRes, TErr>> {
        var cfg:BuildConfig = {
            names: [],
            nomake: false
        };

        switch ( rest ) {
            // no rest arguments
            case []:
                null;

            // single, boolean rest argument
            case [{pos:_,expr:EConst(CIdent(ident))}] if (ident == 'true' || ident == 'false'):
                cfg.nomake = (ident == 'true');

            default:
                null;
        }
        
        var executorExpr:Expr = build_exec(e, cfg);

        // the final product
        return macro new tannus.async.Future($executorExpr, $v{cfg.nomake});
    }

#if macro

    /**
      * generate and return an expression for a FutureExecutor function
      */
    private static function build_exec(e:Expr, cfg:BuildConfig, _map:Bool=true):Expr {
        var orig_e:Expr = e;
        if ( _map ) {
            e = create_mapper(e, cfg).map(create_mapper.bind(_, cfg));
        }
        var exec:Expr = e.buildFunction(['out'], true);
        return exec;
    }

    /**
      * method used to transform the syntax used within Future.create(...) into a functional declaration of a Future
      */
    private static function create_mapper(e:Expr, cfg:BuildConfig):Expr {
        var out:Expr = macro out;
        var cm:Expr->Expr = create_mapper.bind(_, cfg);

        switch e {
            case macro return $ret:
                switch ret {
                    case macro @ignore $ret:
                        return macro return $ret;

                    case macro @await $expr:
                        var res:Expr = macro {
                            var _res = $expr;
                            if ((_res is tannus.async.Future<Dynamic, Dynamic>))
                                $out.wait(cast _res);
                            else if ((_res is tannus.async.Promise<Dynamic, Dynamic>))
                                $out.trust(cast _res);
                            else {
                                $out.wait(_res);
                            }
                        };
                        return res;

                    case _:
                        return macro $out.yield($ret);
                }

            case macro throw $err:
                return macro $out.raise($err);

            case macro @ignore $e:
                return e;

            default:
                return e.map( cm );
        }
    }

#end
}

/*
   the current status of a Future
*/
enum FutureStatus<TSuccess, TFailure> {
    FSUnmade;
    FSPending;
    FSReached(result: Result<TSuccess, TFailure>);
}

/*
  abstract type representing the 'body' function of a Future object
*/
@:callable
@:forward
abstract FutureExecutor<TRes, TErr> (FutureExecutorFunction<TRes, TErr>) from FutureExecutorFunction<TRes, TErr> {
    /* Constructor Function */
    public inline function new(exec : FutureExecutorFunction<TRes, TErr>):Void {
        this = exec;
    }
}

/*
   alias typedef for the 'body' function of a Future
*/
typedef FutureExecutorFunction <TRes, TErr> = FutureResolutionProvider<TRes, TErr> -> Void;

//typedef FutureResolution <TRes, TErr> = EitherType<EitherType<Result<TRes, TErr>, Future<TRes, TErr>>, Promise<FutureResolution<TRes, TErr>>>;

@:callable
@:forward
abstract FutureResolutionProvider<TRes, TErr> (FrpFunc<TRes, TErr>) from FrpFunc<TRes, TErr> {
    /* Constructor Function */
    public function new(give: FutureResolution<TRes, TErr>->Void) {
        this = give;
    }

/* === Instance Methods === */

    @:native('_yield')
    public inline function yield(value: TRes) {
        //give(Result.ResSuccess( value ));
        resolve(Res.value(value));
    }

    @:native('_raise')
    public inline function raise(value: TErr) {
        resolve(Res.error(value));
    }

    public inline function wait(future: Future<TRes, TErr>) {
        resolve(Res.future( future ));
    }

    public inline function trust(promise: Promise<FutureResolution<TRes, TErr>>) {
        resolve(Res.promise(promise));
    }

    public inline function give(result: Result<TRes, TErr>) {
        this(Res.result(result));
    }

    public inline function resolve(resolution: FutureResolution<TRes, TErr>) {
        this(resolution);
    }

    public inline function doGive(result: FutureResolution<TRes, TErr>):Void->Void {
        return this.bind(result);
    }

    public inline function doGiveResult(result: Result<TRes, TErr>):Void->Void {
        return doGive( result );
    }
}

typedef FrpFunc<V,E> = FutureResolution<V, E> -> Void;
//typedef TFRes<TRes, TErr> = EitherType<EitherType<Result<TRes, TErr>, Future<TRes, TErr>>, Promise<FutureResolution<TRes, TErr>>>;
enum TFRes<T, E> {
    //RValue(v: T): TFRes<T, E>;
    //RError(e: E): TFRes<T, E>;
    RResult(r: Result<T, E>): TFRes<T, E>;
    RFuture(f: Future<T, E>): TFRes<T, E>;
    RPromise(p: Promise<FutureResolution<T, E>>): TFRes<T, E>;
}

@:forward
abstract FutureResolution<TRes, TErr> (TFRes<TRes, TErr>) from TFRes<TRes, TErr> to TFRes<TRes, TErr> {
    public inline function new(res : TFRes<TRes, TErr>):Void {
        this = res;
    }

    public var type(get, never): TFRes<TRes, TErr>;
    inline function get_type() return this;

    //public inline function isPlainValue():Bool return type.match(RValue(_));
    //public inline function isPlainError():Bool return type.match(RError(_));
    public inline function isResult():Bool return type.match(RResult(_));
    public inline function isPromise():Bool return type.match(RPromise(_));
    public inline function isFuture():Bool return (this is Future<TRes, TErr>);

    @:to
    public function asFuture():Future<TRes, TErr> {
        return switch type {
            case RResult(res): new Future(function(_) _.resolve(res));
            case RFuture(fut): fut;
            //case RValue(val): Future.resolve(val);
            //case RError(err): Future.error(err);
            case RPromise(prom): prom.future().derive(function(root, out) {
                root.then(function(outcome: Result<FutureResolution<TRes, TErr>, TErr>) {
                    switch outcome {
                        case ResSuccess(fres):
                            out.resolve(fres);

                        case ResFailure(err):
                            out.raise(err);
                    }
                });
            });
        }
    }

    @:to
    public function asResult():Result<TRes, TErr> {
        return switch type {
            case RResult(res): res;
            //case RValue(v): Result.ResSuccess(v);
            //case RError(e): Result.ResFailure(e);
            case _: throw 'Error: Cannot convert $type to Result<T, E>';
        }
    }

    @:from
    public static inline function future<TRes, TErr>(p:Future<TRes, TErr>):FutureResolution<TRes, TErr> return TFRes.RFuture( p );

    @:from
    public static inline function promise<T, E>(p: Promise<FutureResolution<T, E>>):FutureResolution<T, E> return TFRes.RPromise( p );

    @:from
    public static inline function result<T, E>(r: Result<T, E>):FutureResolution<T, E> return TFRes.RResult( r );

    @:from
    public static inline function value<T,E>(v: T):FutureResolution<T,E> return result(ResSuccess(v));

    @:from
    public static inline function error<T,E>(e: E):FutureResolution<T,E> return result(ResFailure(e));
}
private typedef Res<T,E> = FutureResolution<T, E>;

class DerivedFuture<ARes, AErr, BRes, BErr> extends Future<BRes, BErr> {
    /* Constructor Function */
    public function new(ext:Future<ARes, AErr> -> FutureResolutionProvider<BRes, BErr> -> Void, parent:Future<ARes, AErr>, ?nomake:Bool):Void {
        super(function(res) {
            ext(parent, res);
        });
    }
}

class TransformedFuture<TIn, TOut, TErr1, TErr2> extends Future<TOut, TErr2> {
    /* Constructor Function */
    public function new(parent:Future<TIn, TErr1>, transform:{?v:TIn->FutureResolution<TOut, TErr2>, ?e:TErr1->TErr2}) {
        super((x -> null), true);

        this.parent = parent;
        this.parent._attach( this );

        var tv:TIn->TOut = untyped transform.v,
        te:TErr1->TErr2 = untyped transform.e;

        if (tv == null)
            tv = untyped FunctionTools.identity;

        if (te == null)
            tv = untyped FunctionTools.identity;

        exec = (function(res) {
            parent.then(function(presult: Result<TIn, TErr1>) {
                res(switch ( presult ) {
                    case ResSuccess(val): ResSuccess(tv(val));
                    case ResFailure(err): ResFailure(te(err));
                });
            });
        });

        _make();
    }

/* === Instance Methods === */

/* === Instance Fields === */

    private var parent : Future<TIn, TErr1>;
}

private typedef BuildConfig = {
    names: Array<Expr>,
    nomake: Bool
};
