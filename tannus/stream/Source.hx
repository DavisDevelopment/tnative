package tannus.stream;

import tannus.ds.dict.DictKey;
import tannus.ds.Pair;
import tannus.ds.Delta;
import tannus.io.Signal;
import tannus.io.VoidSignal;

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
using tannus.FunctionTools;
using tannus.async.Result;
using tannus.async.OptionTools;

using haxe.macro.ExprTools; 
using haxe.macro.TypeTools;
using haxe.macro.ComplexTypeTools;
using tannus.macro.MacroTools;

class Source <TItem> {
    /* Constructor Function */
    public function new():Void {
        status = SSUntouched;
        //flowType = Paused;
        //buffer = new Array();
        itemSig = new Signal();
        closeSig = new VoidSignal();
        errorSig = new Signal();
        //dataAvailableSig = new VoidSignal();

        b = Broker.create();
        b.itemPolicy = ItemPolicy.Many;
        b.eagerItemPolicy = EagerItemPolicy.Error;
        b.emptyItemPolicy = EmptyItemPolicy.Ignore;

        _bind_( b );

        b.begin(Some(0));
    }

/* === Instance Methods === */

    /**
      attach [this] Source object to the underlying Broker instance
     **/
    function _bind_(b: Broker<Int, TItem, Dynamic>) {
        b.onError = (function(error: BrokerError<Dynamic>) {
            status = SSErrored( error );
            errorSig.call( error );
        });

        b.onItem = (function(item: Option<TItem>) {
            switch item {
                case Some(value):
                    itemSig.call( value );

                case None:
                    return ;
            }
        });

        b.onEnd = (function(id: Option<Int>) {
            status = SSClosed;
            closeSig.fire();
        });
    }

    public inline function onItem(f:TItem->Void, once:Bool=false) {
        itemSig.listen(f, once);
    }
    public inline function onceItem(f:TItem->Void) {
        onItem(f, true);
    }

    public inline function onClose(f:Void->Void, once:Bool=false) {
        if ( once ) {
            closeSig.once( f );
        }
        else {
            closeSig.on( f );
        }
    }

    public inline function onError(f:Dynamic->Void, once:Bool=false) {
        errorSig.listen(f, once);
    }
    public inline function onceError(f: Dynamic->Void) {
        onError(f, true);
    }

/* === Computed Instance Fields === */

    public var status(default, set): SourceState<TItem>;
    private function set_status(v) {
        //var old = this.status;
        var ret = (this.status = v);
        return ret;
    }

    public var writer(get, never): SourceWriter<TItem>;
    private inline function get_writer():SourceWriter<TItem> return b;

/* === Instance Fields === */

    var b: Broker<Int, TItem, Dynamic>;
    //var buffer: Array<TItem>;
    //var flowType: FlowType;
    var itemSig: Signal<TItem>;
    var closeSig: VoidSignal;
    var errorSig: Signal<Dynamic>;
    //var dataAvailableSig: VoidSignal;
}

enum SourceResult<T> {
    SRData(data: T);
    SRNone;
    SREnd;
}

enum FlowType {
    Paused(prev: Option<FlowType>);
    Flowing;
}

enum SourceState<T> {
    SSUntouched;
    SSFlowing;
    SSClosed;

    SSErrored(error: Dynamic);
}

abstract SourceWriter<T> (Broker<Int, T, Dynamic>) from Broker<Int, T, Dynamic> {
    public inline function new(broker) {
        this = broker;
    }

/* === Instance Methods === */

    public inline function push(value: T):SourceWriter<T> {
        this.item(Some( value ));
        return this;
    }

    public inline function error(e: Dynamic):SourceWriter<T> {
        this.fail( e );
        return this;
    }

    public inline function close():SourceWriter<T> {
        this.end(Some(0));
        return this;
    }

    public inline function pause():SourceWriter<T> {
        this.pause();
        return this;
    }

    public inline function resume():SourceWriter<T> {
        this.resume();
        return this;
    }

    public inline function isPaused():Bool return this.isPaused();
}
