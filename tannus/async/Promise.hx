package tannus.async;

import tannus.ds.Delta;
import tannus.io.Signal;
import tannus.io.Signal2;

import tannus.async.promises.*;

import haxe.extern.EitherType as Either;
import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.Context;

import Slambda.fn;
import Reflect.deleteField;

using Slambda;
using tannus.ds.ArrayTools;
using tannus.async.PromiseTools;

using haxe.macro.ExprTools;
using haxe.macro.TypeTools;
using haxe.macro.ComplexTypeTools;
using tannus.macro.MacroTools;

class Promise<T> implements Thenable<T, Promise<T>> {
    /* Constructor Function */
    public function new(exec:PromiseExecutor<T>, nomake:Bool=false):Void {
        this.exec = exec;
        //this.statusChange = new Signal();
        this.status = PSUnmade;
        this._dependants = new Array();
        this.signals = {
            resolve : new Signal(),
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
    public function then(onResolved:T->Void, ?onRejected:Dynamic->Void):Promise<T> {
        //var listener:PromiseListener<T> = PromiseListener(resolved, rejected);
        switch (getStatus()) {
            // [this] Promise is already resolved
            case PSResolved( result ):
                onResolved( result );

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
    public function unless(onRejected:Dynamic->Void, ?testError:Dynamic->Bool):Promise<T> {
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
    public function always(action : Void -> Void):Void {
        then((x)->action(), (x)->action());
    }

    /**
      * create and return a new Promise derived from [this] one
      */
    public function derive<TOut>(extender:Promise<T>->(PromiseResolution<TOut>->Void)->(Dynamic->Void)->Void, ?nomake:Bool):Promise<TOut> {
        return new DerivedPromise(extender, this, nomake);
    }

    /**
      * promise a transformation on [this] Promise's data
      */
    public function transform<TOut, TRes:PromiseResolution<TOut>>(transformer:T->TRes, ?nomake:Bool):Promise<TOut> {
        return derive(function(_from, resolve, reject) {
            _from.then((result) -> resolve(untyped transformer( result )), reject);
        }, nomake);
    }

    /**
      * 'make' [this] Promise
      */
    private function _make():Void {
        function resolve(res) {
            _resolve( res );
        }
        function reject(err) {
            _reject( err );
        }
        setStatus(PSPending);
        exec(resolve, reject);
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
    private function _resolve(resolution : PromiseResolution<T>):Void {
        if (resolution.isPromise()) {
            resolution.asPromise().then(_resolve, _reject);
        }
        else {
            setStatus(PSResolved(resolution.asValue()));
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
    @:noCompletion
    public function _attach<A>(child : Promise<A>):Promise<A> {
        if (!_dependants.has( child )) {
            _dependants.push( child );
        }
        return child;
    }

    /**
      * assign the value of [status]
      */
    private function setStatus(s : PromiseStatus<T>):Void {
        status = s;
    }

    /**
      * handle the changing of [status]
      */
    private function statusChanged(d : Delta<PromiseStatus<T>>):Void {
        if (d.current != null) {
            var newStatus:PromiseStatus<T> = d.current;
            switch ( newStatus ) {
                case PSUnmade:
                    //

                // when [this] Promise is made, ensure that its 'children' are also made
                case PSPending:
                    for (child in _dependants) {
                        child.make();
                    }

                case PSResolved( result ):
                    signals.resolve.broadcast( result );
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
    public inline function getStatus():PromiseStatus<T> {
        return status;
    }

    public inline function isUnmade():Bool {
        return (getStatus().equals(PSUnmade));
    }

    public inline function isPending():Bool {
        return (getStatus().equals(PSPending));
    }

    public inline function isSettled():Bool {
        return (getStatus().match(PSResolved(_)|PSRejected(_)));
    }

    public inline function isUnsettled():Bool {
        return (getStatus().match(PSUnmade|PSPending));
    }

/* === Casting Methods === */

    //public function string():StringPromise {
        //return new StringPromise(untyped this);
    //}
    public macro function string(self:Expr):ExprOf<StringPromise> {
        return macro new StringPromise($self);
    }

    public macro function bool(self:ExprOf<Promise<Bool>>):ExprOf<BoolPromise> {
        return macro new BoolPromise($self);
    }

    public macro function array(self:ExprOf<Promise<Array<T>>>):ExprOf<ArrayPromise<T>> {
        return macro new ArrayPromise($self);
    }

#if js

    public function toJsPromise():js.Promise<T> {
        return new js.Promise(function(a, b) {
            untyped then(a, b);
        });
    }

    public static function fromJsPromise<T>(jsprom : js.Promise<T>):Promise<T> {
        return new Promise(function(a, b) {
            untyped jsprom.then(a, b);
        });
    }

#end

/* === Computed Instance Fields === */

    private var status(default, set):PromiseStatus<T>;
    private function set_status(newStatus : PromiseStatus<T>):PromiseStatus<T> {
        var old:Null<PromiseStatus<T>> = status;
        status = newStatus;
        //statusChange.call(new Delta(status, old));
        statusChanged(new Delta(status, old));
        return status;
    }

/* === Instance Fields === */

    private var exec : PromiseExecutor<T>;
    private var signals : Null<{resolve:Signal<T>, reject:Signal<Dynamic>}>;
    private var _dependants : Array<Promise<Dynamic>>;

/* === Static Methods === */

    public static function resolve<T>(res : PromiseResolution<T>):Promise<T> {
        return new Promise(function(_resolve, _throw) {
            _resolve( res );
        });
    }

    public static function all(proms : Iterable<Promise<Dynamic>>):Promise<Array<Dynamic>> {
        return new Promise(function(yes, no) {
            var values:Array<Dynamic> = [];
            var resolved:Int = 0, total:Int = 0;

            function make_step(i:Int, promise:Promise<Dynamic>) {
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

    public static function _settle<T>(res:PromiseResolution<T>, onValue:T->Void, ?onError:Dynamic->Void):Void {
        if (res.isPromise()) {
            res.asPromise().then(onValue, onError);
        }
        else {
            onValue(res.asValue());
        }
    }

    /**
      * declarative, less bulky (than using the constructor) macro for creating new promises
      */
    public static macro function create<T>(e:Expr, rest:Array<Expr>):ExprOf<Promise<T>> {
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
        return macro new tannus.async.Promise($executorExpr, $v{cfg.nomake});
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

enum PromiseStatus<T> {
    PSUnmade;
    PSPending;
    PSResolved(result : T);
    PSRejected(reason : Dynamic);
}

@:callable
@:forward
abstract PromiseExecutor<T> (PromiseExecutorFunction<T>) from PromiseExecutorFunction<T> {
    public inline function new(exec : PromiseExecutorFunction<T>):Void {
        this = exec;
    }
}

typedef PromiseExecutorFunction<T> = (PromiseResolution<T> -> Void) -> (Dynamic->Void) -> Void;

typedef PromiseResolution<T> = Either<T, Promise<T>>;

/*
@:forward
abstract PromiseResolution<T> (Either<T, Promise<T>>) from Either<T, Promise<T>> to Either<T, Promise<T>> {
    public inline function new(res : Either<T,Promise<T>>) {
        this = res;
    }
    public inline function isPromise():Bool return (this is Promise<T>);
    @:to
    public inline function asPromise():Promise<T> return this;
    @:to
    public inline function asValue():T return this;
    @:from
    public static inline function fromAny<T>(v : Dynamic):PromiseResolution<T> {
        return new PromiseResolution( v );
    }
}
*/

class DerivedPromise<TIn, TOut> extends Promise<TOut> {
    /* Constructor Function */
    public function new(ext:Promise<TIn>->(PromiseResolution<TOut>->Void)->(Dynamic->Void)->Void, parent:Promise<TIn>, ?nomake:Bool):Void {
        super(function(resolve, reject) {
            ext(parent, resolve, reject);
        });
    }
}

class TranformedPromise<TIn, TOut> extends Promise<TOut> {
    /* Constructor Function */
    public function new(parent:Promise<TIn>, transform:TIn->TOut) {
        super(((x,y) -> null), true);

        this.parent = parent;

        exec = (function(resolve, reject) {
            parent.then((x)->resolve(transform( x )), reject);
        });

        _make();
    }

/* === Instance Methods === */

/* === Instance Fields === */

    private var parent : Promise<TIn>;
}

private typedef BuildConfig = {
    names: Array<Expr>,
    nomake: Bool
};