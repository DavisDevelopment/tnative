package tannus.async;

import tannus.ds.dict.DictKey;
import tannus.ds.Pair;
import tannus.ds.Delta;
import tannus.io.Signal;
import tannus.io.Signal2;

import tannus.async.Result;
import tannus.async.AsyncError;

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
using tannus.FunctionTools;
using tannus.async.Result;
using tannus.async.OptionTools;

using haxe.macro.ExprTools; using haxe.macro.TypeTools;
using haxe.macro.ComplexTypeTools;
using tannus.macro.MacroTools;

@:forward
abstract Broker<UId:DictKey, Item, Error> (BrokerObject<UId, Item, Error>) from BrokerObject<UId, Item, Error> to BrokerObject<UId, Item, Error> {
    /* Constructor Function */
    public inline function new(bo: BrokerObject<UId, Item, Error>):Void {
        this = bo;
    }

/* === Instance Methods === */

/* === Static Methods === */

    public static inline function isBroker(x: Dynamic):Bool {
        return Std.is(x, BrokerObject);
    }

    public static inline function create<Id:DictKey, Item, Error>():Broker<Id, Item, Error> {
        return new Broker(new BrokerObjectBase());
    }
}

interface BrokerObject<UId:DictKey, Item, Error> {
    function begin(?id: Option<UId>):Void;
    function end(?id: Option<UId>):Void;
    function throwError(error: BrokerError<Error>):Void;
    function fail(error: Error):Void;
    function item(i: Option<Item>):Void;
    function put(item: Item):Void;
    function watch(observer: BrokerEvent<UId, Item, Error>->Void):Void;
    function ignore(observer: BrokerEvent<UId, Item, Error>->Void):Void;
    function broadcast(event: BrokerEvent<UId, Item, Error>):Void;
    function isPaused():Bool;
    function pause():Bool;
    function resume():Bool;
    function flush():Void;

    dynamic function handleEvent(event: BrokerEvent<UId, Item, Error>):Void;
    dynamic function onError(error: BrokerError<Error>):Void;
    dynamic function onBegin(id: Option<UId>):Void;
    dynamic function onEnd(id: Option<UId>):Void;
    dynamic function onItem(item: Option<Item>):Void;

    var status(default, set): BrokerStatus<Item, Error>;
    var itemPolicy: ItemPolicy;
    var eagerItemPolicy: EagerItemPolicy;
    var emptyItemPolicy: EmptyItemPolicy;
}

class BrokerObjectBase<UId:DictKey, Item, Error> implements BrokerObject<UId, Item, Error> {
    /* Constructor Function */
    public function new():Void {
        eventSignal = new Signal();
        _paused = false;
        eventBuffer = new Array();
        eagerItemPolicy = EagerItemPolicy.Ignore;
        emptyItemPolicy = EmptyItemPolicy.Ignore;
        itemPolicy = ItemPolicy.Many;

        status = BSStandby;

        watch(function(event) {
            handleEvent( event );
        });
    }

/* === Instance Methods === */

    public dynamic function onItem(item: Option<Item>) {
        //
    }

    public dynamic function onError(error: BrokerError<Error>) {
        //
    }

    public dynamic function onBegin(id: Option<UId>) {
        //
    }

    public dynamic function onEnd(id: Option<UId>) {
        //
    }

    public dynamic function handleEvent(event: BrokerEvent<UId, Item, Error>) {
        switch event {
            case BrokerEvent.EBegin(uid):
                onBegin( uid );

            case BrokerEvent.EEnd(uid):
                onEnd( uid );

            case BrokerEvent.EItem(item):
                onItem( item );

            case BrokerEvent.EError(error):
                onError( error );

            case BrokerEvent.EStatusChange(status):
                null;
        }
    }

    public function isPaused():Bool {
        return _paused;
    }

    public function pause():Bool {
        var ret = !isPaused();
        _paused = true;
        return ret;
    }

    public function resume():Bool {
        var ret = isPaused();
        _paused = false;
        flush();
        return ret;
    }

    public function flush():Void {
        while (eventBuffer.length > 0) {
            eventSignal.call(eventBuffer.shift());
        }
    }

    public function put(item: Item) {
        return this.item(Some(item));
    }

    public function item(i: Option<Item>) {
        if (!isValidCall()) return ;
    
        switch i {
            case None:
                switch emptyItemPolicy {
                    case Default:
                        null;

                    case EmptyItemPolicy.Error:
                        throwError(EEmptyItem);

                    case EmptyItemPolicy.Ignore:
                        return ;

                    case EmptyItemPolicy.ImplicitClose:
                        return end(null);
                }

            case Some(value):
                switch status {
                    case BSFlowing:
                        broadcast(EItem(Some(value)));

                    case BSStandby:
                        switch eagerItemPolicy {
                            case EagerItemPolicy.Error:
                                throwError(EEagerItem);

                            case EagerItemPolicy.Ignore:
                                return ;

                            case EagerItemPolicy.ImplicitBegin:
                                return begin(null);
                        }

                    case BSFailed(_):
                        throw EInvalidCall('item', 'cannot push item onto an errored-out context');

                    case BSEnded:
                        return ;
                }
        }
    }

    public function begin(?id: Option<UId>) {
        if (id == null)
            id = None;

        switch status {
            case BSStandby|BSEnded:
                broadcast(EBegin( id ));
                status = BSFlowing;

            case BSFailed(_):
                broadcast(EBegin( id ));
                status = BSFlowing;

            case BSFlowing:
                return throwError(EInvalidCall('begin', 'is already open, cannot open again'));
        }
    }

    public function end(?id: Option<UId>) {
        if (id == null)
            id = None;
        switch status {
            case BSFlowing:
                broadcast(EEnd( id ));
                status = BSEnded;

            case BSEnded:
                return throwError(EInvalidCall('end', '.end cannot be called twice in a row'));

            case BSStandby:
                return throwError(EInvalidCall('end', '.begin has not been called; cannot end'));

            case BSFailed(_):
                throw EInvalidCall('end', '.begin has not been called; cannot end');
        }
    }

    public function fail(error: Error) {
        if (!isValidCall()) {
            return ;
        }
        else {
            return throwError(EFailure( error ));
        }
    }

    public function throwError(error: BrokerError<Error>) {
        if (!isValidCall()) {
            return ;
        }
        else {
            broadcast(EError( error ));
            status = BSFailed( error );
            return ;
        }
    }

    public function watch(f: BrokerEvent<UId, Item, Error>->Void) {
        eventSignal.on( f );
    }

    public function ignore(f: BrokerEvent<UId, Item, Error>->Void) {
        eventSignal.off( f );
    }

    public function broadcast(event: BrokerEvent<UId, Item, Error>) {
        if (isPaused()) {
            eventBuffer.push( event );
        }
        else {
            eventSignal.call( event );
        }
    }

    function statusChanged(oldStatus:BrokerStatus<Item, Error>, newStatus:BrokerStatus<Item, Error>) {
        switch [oldStatus, newStatus] {
            default:
                return ;
        }

        broadcast(EStatusChange( newStatus ));
    }

    function isValidCall():Bool {
        if (status.match(BSFailed(_))) {
            return false;
        }
        else {
            return true;
        }
    }

/* === Computed Instance Fields === */

    public var status(default, set): BrokerStatus<Item, Error>;
    function set_status(v: BrokerStatus<Item, Error>) {
        var old = status;
        var ret = this.status = v;
        statusChanged(old, ret);
        return ret;
    }

/* === Instance Fields === */

    public var itemPolicy: ItemPolicy;
    public var eagerItemPolicy: EagerItemPolicy;
    public var emptyItemPolicy: EmptyItemPolicy;

    var eventSignal: Signal<BrokerEvent<UId, Item, Error>>;
    var _paused: Bool;
    var eventBuffer: Array<BrokerEvent<UId, Item, Error>>;
}

enum BrokerEvent<UId, Item, Error> {
    EBegin(id: Option<UId>);
    EItem(item: Option<Item>);
    EEnd(id: Option<UId>);

    EError(error: BrokerError<Error>);
    EStatusChange(status: BrokerStatus<Item, Error>);
}

enum BrokerStatus<Item, Error> {
    /* the Broker has failed */
    BSFailed(error: BrokerError<Error>);

    /* the Broker has data flowing currently */
    BSFlowing();

    BSStandby();
    BSEnded();
}

enum EagerItemPolicy {
    //Default;
    ImplicitBegin;
    Ignore;
    Error;
}

enum EmptyItemPolicy {
    Default;
    Ignore;
    Error;
    ImplicitClose;
}

enum ItemPolicy {
    Single;
    Many;
}

enum BrokerError<T> {
    EFailure(error: T);
    EEmptyItem;
    EEagerItem;
    EInvalidCall(method:String, reason:String);
}

interface Betty {}
