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
    public function derive<OutRes,OutErr>(extender:Future<TRes,TErr>->FutureResolutionProvider<OutRes,OutErr>)->Void, ?nomake:Bool):Future<OutRes,OutErr> {
        return new DerivedFuture(extender, this, nomake);
    }

    /**
      * promise a transformation on [this] Future's data
      */
    public function transform<Out, Err>(?mapv:TRes->Out, ?mape:TErr->Err, ?nomake:Bool):Future<Out, Err> {
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
    private function _resolve<Res:FutureResolution<TRes, TErr>>(resolution : Res):Void {
        if (resolution.isResult()) {
            setStatus(FSReached(resolution.asResult()));
        }
        else if (resolution.isPromise()) {
            resolution.asPromise().then(_resolve, function(error) {
                //FIXME
                throw error;
            });
        }
        else if (resolution.isFuture()) {
            //TODO
        }
        else {
            throw 'Error: Unhandled Future resolution value $resolution';
        }
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
        child.then(function(out: Result<TRes,SubErr>) {
            switch ( out ) {
                case ResSuccess( value ):
                    if (value.isResult() || value.isFuture() || value.isPromise()) {
                        _resolve( value );
                    }
                    else {
                        _resolve(ResSuccess( value ));
                    }

                case ResFailure( error ):
                    _resolve(Result.ResFailure(translateError(error)));
            }
            //betty
        });
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
        return (getStatus().match(FSResolved(_)|FSRejected(_)));
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

    public static function resolve<TRes, TErr, R:FutureResolution<TRes, TErr>>(res : R):Future<TRes, TErr> {
        return new Future(function(_resolve:FutureResolutionProvider<TRes, TErr>) {
            _resolve(untyped res);
        });
    }

    public static function pair<A, B>(resPair : Pair<FutureResolution<A>, FutureResolution<B>>):Future<Pair<A, B>> {
        return all(untyped [resolve(resPair.left), resolve(resPair.right)]).transform(function(a : Array<Dynamic>) {
            return untyped (new Pair(untyped a[0], untyped a[1]));
        });
    }

    public static function all(proms : Iterable<Future<Dynamic>>):Future<Array<Dynamic>> {
        return new Future(function(yes, no) {
            var values:Array<Dynamic> = [];
            var resolved:Int = 0, total:Int = 0;

            function make_step(i:Int, promise:Future<Dynamic>) {
                promise.then(function(value:Dynamic) {
                    values[i] = value;
                    if (resolved == total) {
                        yes( values );
                    }
                }, no);
            }

            var index:Int = 0;
            for (prom in proms) {
                total++;
                make_step(index, prom);
                index++;
            }
        });
    }

    public static function _settle<TRes, TErr>(res:FutureResolution<TRes, TErr>, onValue:T->Void, ?onError:Dynamic->Void):Void {
        if (res.isFuture()) {
            res.asFuture().then(onValue, onError);
        }
        else {
            onValue(res.asValue());
        }
    }

    /**
      * declarative, less bulky (than using the constructor) macro for creating new promises
      */
    public static macro function create<TRes, TErr>(e:Expr, rest:Array<Expr>):ExprOf<Future<TRes, TErr>> {
        var yes:Expr = (macro accept);
        var no:Expr = (macro reject);
        var cfg:BuildConfig = {
            names: [yes, no],
            nomake: false
        };

        switch ( rest ) {
            // no rest arguments
            case []:
                null;

            // single, boolean rest argument
            case [{pos:_,expr:EConst(CIdent(ident))}] if (ident == 'true' || ident == 'false'):
                cfg.nomake = (ident == 'true');

            case [{pos:_,expr:EArrayDecl([yep, nope])}]:
                cfg.names = [yep, nope];

            default:
                null;
        }
        
        var executorExpr:Expr = build_exec(e, cfg);
        //trace(executorExpr.toString());

        // the final product
        return macro new tannus.async.Future($executorExpr, $v{cfg.nomake});
    }

#if macro

    /**
      * generate and return an expression for a FutureExecutor function
      */
    private static function build_exec(e:Expr, cfg:BuildConfig, _map:Bool=true):Expr {
        var yes:Expr = cfg.names[0], no:Expr = cfg.names[1];
        var orig_e:Expr = e;
        if (_map) {
            e = create_mapper(e, cfg).map(create_mapper.bind(_, cfg));
        }
        var exec:Expr = e.buildFunction([yes.toString(), no.toString()], true);
        return exec;
    }

    /**
      * method used to transform the syntax used within Future.create(...) into a functional declaration of a Future
      */
    /*
    private static function create_mapper(e:Expr, cfg:BuildConfig):Expr {
        var yes:Expr = cfg.names[0], no:Expr = cfg.names[1];
        var cm:Expr->Expr = create_mapper.bind(_, cfg);

        switch ( e.expr ) {
            case EReturn( res ):
                var resolution:Expr = res.map( cm );
                return macro $yes($resolution);

            case EThrow( err ):
                return macro $no( $err );

            // metadata
            case EMeta(meta, expr):
                switch ( meta.name ) {
                    case 'ignore':
                        return e;

                    case 'forward':
                        return macro $expr.then($yes, $no);

                    case 'promise':
                        var _cast:Bool = false;
                        var _untyped:Bool = false;
                        if (meta.params != null) {
                            switch ( meta.params ) {
                                case [_.expr=>EConst(CIdent(m))]:
                                    if (m == '_cast_') {
                                        _cast = true;
                                    }
                                    else if (m == '_untyped_') {
                                        _untyped = true;
                                    }

                                default:
                                    null;
                            }
                        }
                        switch ( expr.expr ) {
                            case ECall(fExpr, fArgs):
                                var yesArg:Expr = yes, noArg:Expr = no;
                                if ( _cast ) {
                                    yesArg = macro cast $yesArg;
                                    noArg = macro cast $noArg;
                                }
                                else if ( _untyped ) {
                                    yesArg = macro untyped $yesArg;
                                    noArg = macro untyped $noArg;
                                }
                                fArgs.push( yesArg );
                                fArgs.push( noArg );
                                return {
                                    pos: expr.pos,
                                    expr: ECall(fExpr, fArgs)
                                };

                            default:
                                throw 'Error: Invalid use @promise in Future.create';
                        }

                    case 'exec':
                        var ecfg:BuildConfig = {nomake:cfg.nomake, names:[macro resolve, macro reject]};
                        if (meta.params != null) {
                            switch ( meta.params ) {
                                case [{pos:_, expr:EArrayDecl(configNames)}]:
                                    ecfg.names = configNames;

                                default:
                                    null;
                            }
                        }
                        return build_exec(create_mapper(expr, ecfg), ecfg);

                    case 'create':
                        var ecfg:BuildConfig = {nomake:cfg.nomake, names:[macro resolve, macro reject]};
                        if (meta.params != null) {
                            switch ( meta.params ) {
                                case [{pos:_, expr:EArrayDecl(configNames)}]:
                                    ecfg.names = configNames;

                                default:
                                    null;
                            }
                        }
                        var executor:Expr = build_exec(create_mapper(expr, ecfg), ecfg);
                        return macro new tannus.async.Future($executor);

                    case 'with':
                        trace('@with is urinal magic, Betty');
                        return expr;

                    default:
                        return e;
                }

            default:
                return e.map( cm );
        }
    }

    private static function build_with(ctx:Expr, e:Expr):Expr {
        switch ( e.expr ) {
            case ETry(tryExpr, catches):
                //var checks = [];
                var handlers = [];
                for (c in catches) {
                    var checkExpr:Expr = {pos:e.pos, expr:ECheckType(macro x, c.type)};
                    trace(checkExpr.toString());
                    //checks.push(macro (x) -> $checkExpr);

                    var handlerExpr = c.expr.buildFunction([c.name], true);
                    trace(handlerExpr.toString());
                    handlers.push({
                        check: (macro (x) -> $checkExpr),
                        f: handlerExpr
                    });
                }
                var blockBody:Array<Expr> = [];
                var catchStatements:Array<Expr> = handlers.map(h -> macro $ctx.unless(${h.f}, ${h.check}));
                var tryStatement:Expr = tryExpr.replace(macro _, macro result).buildFunction(['result'], true);
                trace(tryStatement.toString());
                tryStatement = macro $ctx.then( $tryStatement );
                trace(tryStatement.toString());
                blockBody = [tryStatement].concat( catchStatements );
                var block = macro $b{blockBody};
                trace(block.toString());
                return block;

            case EBlock(_[0] => firstExpr) if (firstExpr != null):
                return build_with(ctx, firstExpr);

            case ExprDef.EParenthesis(pe):
                return build_with(ctx, pe);

            default:
                return e;
        }
    }
    */

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

typedef FutureResolution <TRes, TErr> = EitherType<EitherType<Result<TRes, TErr>, Future<TRes, TErr>>, Promise<FutureResolution>>;

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
        this(Result.ResSuccess( value ));
    }

    @:native('_raise')
    public inline function raise(value: TErr) {
        this(Result.ResFailure( value ));
    }

    public inline function doGive(result: FutureResolution<TRes, TErr>):Void->Void {
        return this.bind(result);
    }

    public inline function doGiveResult(result: Result<TRes, TErr>):Void->Void {
        return doGive( result );
    }
}

typedef FrpFunc<V,E> = FutureResolution<V, E> -> Void;

/*
@:forward
abstract FutureResolution<TRes, TErr> (TPRes<TRes, TErr>) from TPRes<TRes, TErr> to TPRes<TRes, TErr> {
    public inline function new(res : TPRes<TRes, TErr>):Void {
        this = res;
    }
    public inline function isFuture():Bool return (this is Future<TRes, TErr>);
    @:to
    public inline function asFuture():Future<TRes, TErr> return this;
    @:to
    public inline function asValue():T return this;
    @:from
    public static inline function fromFuture<TRes, TErr>(p:Future<TRes, TErr>):FutureResolution<TRes, TErr> return fromAny( p );
    @:from
    public static inline function fromAny<TRes, TErr>(v : Dynamic):FutureResolution<TRes, TErr> {
        return new FutureResolution( v );
    }
}
*/

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
    public function new(parent:Future<TIn, TErr1>, transform:{?v:TIn->FutureResolution<TOut>, ?e:TErr1->TErr2}) {
        super((x -> null), true);

        this.parent = parent;
        this.parent._attach( this );

        var tv:TIn->TOut = transform.v, te:TErr1->TErr2 = transform.e;
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
