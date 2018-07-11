package tannus.async;

import tannus.ds.Delta;
import tannus.io.Signal;
import tannus.io.VoidSignal;
import tannus.io.Signal2;

import tannus.async.promises.*;

import haxe.extern.EitherType as Either;
import haxe.ds.Option;
import haxe.Constraints.Function;

import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.Context;

import Slambda.fn;
import Reflect.deleteField;

using Slambda;
using tannus.ds.ArrayTools;
using tannus.async.PromiseTools;
using tannus.FunctionTools;
using tannus.async.Result;

using haxe.macro.ExprTools;
using haxe.macro.TypeTools;
using haxe.macro.ComplexTypeTools;
using tannus.macro.MacroTools;

class VoidPromise {
    /* Constructor Function */
    public function new(exec:VoidPromiseExecutor, nomake:Bool=false):Void {
        this.exec = exec;
        //this.statusChange = new Signal();
        this.status = PSUnmade;
        //this._dependants = new Array();
        this.signals = {
            resolve : new VoidSignal(),
            reject  : new Signal()
        };

        if (!nomake) {
            _make();
        }
    }

/* === Instance Methods === */
    
    /**
      * handle the settling of [this] Promise
      */
    public function then(onResolved:Void->Void, ?onRejected:Dynamic->Void):VoidPromise {
        //var listener:PromiseListener<T> = PromiseListener(resolved, rejected);
        switch (getStatus()) {
            // [this] Promise is already resolved
            case PSResolved:
                onResolved();

            // [this] Promise is already rejected
            case PSRejected( reason ):
                if (onRejected != null) {
                    onRejected( reason );
                }

            case PSPending, PSUnmade:
                signals.resolve.on( onResolved );
                if (onRejected != null) {
                    signals.reject.on( onRejected );
                }
        }
        return this;
    }

    /**
      * handle the rejection of [this] Promise
      */
    public function unless(onRejected:Dynamic->Void, ?testError:Dynamic->Bool):VoidPromise {
        switch (getStatus()) {
            case PSRejected( reason ) if (testError == null || testError( reason )):
                onRejected( reason );

            case PSPending, PSUnmade:
                if (testError == null) {
                    signals.reject.on( onRejected );
                }
                else {
                    signals.reject.when(testError, onRejected);
                }

            default:
                null;
        }
        return this;
    }

    /**
      * invoke [action] when [this] promise has been settled, whether resolved or rejected
      */
    public function always(action : Void -> Void):VoidPromise {
        //action = action.once();
        return then(action.once(), (x -> action()).once());
    }

    /**
      * create and return a new Promise derived from [this] one
      */
    /*
    public function derive<TOut>(extender:Promise<T>->(PromiseResolution<TOut>->Void)->(Dynamic->Void)->Void, ?nomake:Bool):Promise<TOut> {
        return new DerivedPromise(extender, this, nomake);
    }
    */

    /**
      * promise a transformation on [this] Promise's data
      */
    /*
    public function transform<TOut, TRes:PromiseResolution<TOut>>(transformer:T->TRes, ?nomake:Bool):Promise<TOut> {
        return derive(function(_from, resolve, reject) {
            _from.then((result) -> resolve(untyped transformer( result )), reject);
        }, nomake);
    }
    */

    /**
      * 'make' [this] Promise
      */
    private function _make():Void {
        //function resolve(?res: VpRes) {
            //_resolve( res );
        //}
        function resolve() {
            _resolve();
        }

        function reject(err) {
            _reject( err );
        }

        setStatus(PSPending);

        exec(resolve.once(), reject.once());
    }

    /**
      * 'make' [this] Promise, if not already made
      */
    public function make():Void {
        if (isUnmade()) {
            _make();
        }
    }

    /**
      * resolve [this] Promise
      */
    private function _resolve(?res: VpRes):Void {
        if (res != null) {
            res.toVp().then(
                function() {
                    setStatus(PSResolved);
                },
                function(error) {
                    setStatus(PSRejected(error));
                }
            );
        }
        else {
            setStatus( PSResolved );
        }
    }

    /**
      * reject [this] Promise
      */
    private function _reject(reason : Dynamic):Void {
        setStatus(PSRejected( reason ));
    }

    /**
      * attach [child] Promise to [this] one
      */
    /*
    @:noCompletion
    public function _attach<A>(child : Promise<A>):Promise<A> {
        if (!_dependants.has( child )) {
            _dependants.push( child );
        }
        return child;
    }
    */

    /**
      * assign the value of [status]
      */
    private function setStatus(s : VoidPromiseStatus):Void {
        status = s;
    }

    /**
      * handle the changing of [status]
      */
    private function statusChanged(d : Delta<VoidPromiseStatus>):Void {
        if (d.current != null) {
            var newStatus:VoidPromiseStatus = d.current;
            switch ( newStatus ) {
                case PSUnmade:
                    //

                // when [this] Promise is made, ensure that its 'children' are also made
                case PSPending:
                    return ;
                    //for (child in _dependants) {
                        //child.make();
                    //}

                case PSResolved:
                    signals.resolve.fire();
                    disposeSignals();

                case PSRejected( reason ):
                    signals.reject.broadcast( reason );
                    disposeSignals();
            }
        }
    }

    /**
      * dispose of [signals] once [this] Promise has been settled. we don't need them anymore
      */
    private function disposeSignals():Void {
        signals.resolve.clear();
        signals.reject.clear();
        signals = null;
    }

/* === Info-Getter Instance Methods === */

    /**
      * get the value of [status]
      */
    public inline function getStatus():VoidPromiseStatus {
        return status;
    }

    public inline function isUnmade():Bool {
        return (getStatus().equals(PSUnmade));
    }

    public inline function isPending():Bool {
        return (getStatus().equals(PSPending));
    }

    public inline function isSettled():Bool {
        return (getStatus().match(PSResolved|PSRejected(_)));
    }

    public inline function isUnsettled():Bool {
        return (getStatus().match(PSUnmade|PSPending));
    }

/* === Casting Methods === */

    //public function string():StringPromise {
        //return new StringPromise(untyped this);
    //}
    /*
    public macro function string(self:Expr):ExprOf<StringPromise> {
        return macro new StringPromise($self);
    }

    public macro function bool(self:ExprOf<Promise<Bool>>):ExprOf<BoolPromise> {
        return macro new BoolPromise($self);
    }

    public macro function array(self:ExprOf<Promise<Array<T>>>):ExprOf<ArrayPromise<T>> {
        return macro new ArrayPromise($self);
    }
    */

    public function error():Promise<Option<Dynamic>> {
        return new Promise<Option<Dynamic>>(function(yep, nope) {
            try {
                function done_success()
                    yep(None);
                function done_failure(failure_reason)
                    yep(Some(failure_reason));
                then(done_success.once(), done_failure.once());
            }
            catch (err: Dynamic) {
                nope( err );
                #if js
                js.Lib.rethrow();
                #end
            }
        });
    }

    /**
      * derive a valued Promise from a Void one
      */
    public function promise<T>(promiser : Void->tannus.async.Promise.PromiseResolution<T>):Promise<T> {
        return new Promise(function(yes, no) {
            then(function() {
                yes(promiser());
            }, no);
        });
    }

#if js

    public function toJsPromise():js.Promise<Dynamic> {
        return new js.Promise(function(a, b) {
            untyped then(untyped a, b);
        });
    }

    /*
    public static function fromJsPromise<T>(jsprom : js.Promise<T>):Promise<T> {
        return new Promise(function(a, b) {
            untyped jsprom.then(a, b);
        });
    }
    */

#end

/* === Computed Instance Fields === */

    private var status(default, set):VoidPromiseStatus;
    private function set_status(newStatus : VoidPromiseStatus):VoidPromiseStatus {
        var old:Null<VoidPromiseStatus> = status;
        status = newStatus;
        //statusChange.call(new Delta(status, old));
        statusChanged(new Delta(status, old));
        return status;
    }

/* === Instance Fields === */

    private var exec : VoidPromiseExecutor;
    private var signals : Null<{resolve:VoidSignal, reject:Signal<Dynamic>}>;
    //private var _dependants : Array<Promise<Dynamic>>;

/* === Static Methods === */

    @:native('_void')
    public static function void(f : Void->Void):VoidPromise {
        return create({
            try {
                f();
                return ;
            }
            catch (error : Dynamic) {
                throw error;
            }
        });
    }

    public static function raise(error: Dynamic):VoidPromise {
        return new VoidPromise(function(_, _throw) {
            _throw( error );
        });
    }

    public static function all(a: Iterable<VoidPromise>):VoidPromise {
        var val = a.array().map(x -> ((next:VoidCb) -> x.then(next.void(), next.raise()) : VoidAsync)).compact();
        return new VoidPromise(function(finish, quit) {
            VoidAsyncs.series(val, function(?err) {
                if (err != null)
                    quit(err);
                else
                    finish();
            });
        });
    }

    public static function fromAsyncs(asyncs: Iterable<VoidAsync>):VoidPromise {
        return all(asyncs.array().map(a -> VoidAsyncs.toPromise(a)));
    }

    /**
      * declarative, less bulky (than using the constructor) macro for creating new promises
      */
    public static macro function create(e:Expr, rest:Array<Expr>):ExprOf<VoidPromise> {
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
        return macro new tannus.async.VoidPromise($executorExpr, $v{cfg.nomake});
    }

#if macro

    /**
      * generate and return an expression for a PromiseExecutor function
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
      * method used to transform the syntax used within Promise.create(...) into a functional declaration of a Promise
      */
    private static function create_mapper(e:Expr, cfg:BuildConfig):Expr {
        var yes:Expr = cfg.names[0], no:Expr = cfg.names[1];
        var cm:Expr->Expr = create_mapper.bind(_, cfg);

        switch ( e.expr ) {
            case EReturn(_):
                //var resolution:Expr = res.map( cm );
                return macro $yes();

            case EThrow( err ):
                return macro $no( $err );

            // metadata
            case EMeta(meta, expr):
                switch ( meta.name ) {
                    case 'ignore':
                        return expr;

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
                                throw 'Error: Invalid use @promise in Promise.create';
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
                        return macro new tannus.async.Promise($executor);

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

#end
}

enum VoidPromiseStatus {
    PSUnmade;
    PSPending;
    PSResolved;
    PSRejected(reason : Dynamic);
}

@:callable
@:forward
abstract VoidPromiseExecutor (VoidPromiseExecutorFunction) from VoidPromiseExecutorFunction {
    public inline function new(exec : VoidPromiseExecutorFunction):Void {
        this = exec;
    }
}

//typedef VoidPromiseExecutorFunction = (?VpRes -> Void) -> (Dynamic->Void) -> Void;
typedef VoidPromiseExecutorFunction = (Void -> Void) -> (Dynamic->Void) -> Void;

abstract VpRes (VpResolution) from VpResolution {
    @:from
    public static inline function fromVpResolution<T:VpResolution>(res: T):VpRes {
        return untyped res;
    }

    @:to
    public static function toVp(res: VpResolution):VoidPromise {
        if ((res is VoidPromise)) {
            return cast res;
        }
        #if js
        else if ((res is js.Promise<Dynamic>)) {
            return toVp(Promise.fromJsPromise(cast res));
        }
        #end
        else if ((res is Promise<Dynamic>)) {
            return (res : Promise<Dynamic>).void();
        }
        else if (Reflect.isFunction( res )) {
            return toVp(new Promise(function(accept, reject) {
                (untyped res)(function(?error:Dynamic, ?result:Dynamic) {
                    if (error != null)
                        reject(error);
                    else
                        accept(result);
                });
            }));
        }
        else {
            return toVp(Promise.resolve(cast res));
        }
    }
}

private typedef VpResolution = Either<#if js Either<Promise<Dynamic>,js.Promise<Dynamic>> #else Promise<Dynamic> #end, Either<VoidPromise, Either<Function->Void, Dynamic>>>;

private typedef BuildConfig = {
    names: Array<Expr>,
    nomake: Bool
};
