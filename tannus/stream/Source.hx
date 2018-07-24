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
        flowType = Paused;
        buffer = new Array();
        itemSig = new Signal();
        closeSig = new VoidSignal();
        dataAvailableSig = new VoidSignal();

        b = Broker.create();
        b.itemPolicy = ItemPolicy.Many;
        b.eagerItemPolicy = EagerItemPolicy.Error;
        b.emptyItemPolicy = EmptyItemPolicy.Ignore;

        _bind_( b );
    }

/* === Instance Methods === */

    /**
      attach [this] Source object to the underlying Broker instance
     **/
    function _bind_(b: Broker<Int, T, Dynamic>) {
        
    }

    public function isDataAvailable():Bool {
        return status.match(SSDataAvailable);
    }

    public function get():SourceResult<TItem> {
        //
    }

/* === Computed Instance Fields === */

    public var status(default, set): SourceState<TItem>;
    private function set_status(v) {
        return this.status = v;
    }

/* === Instance Fields === */

    var b: Broker<Int, TItem, Dynamic>;
    var buffer: Array<TItem>;
    var flowType: FlowType;
    var itemSig: Signal<TItem>;
    var closeSig: VoidSignal;
    var dataAvailableSig: VoidSignal;
}

enum SourceResult<T> {
    SRData(data: T);
    SRNone;
    SREnd;
}

enum FlowType {
    Paused;
    Flowing;
}

enum SourceState<T> {
    SSUntouched;
    SSDataAvailable;
    SSDataEmpty;
    SSClosed;

    SSErrored(error: Dynamic);
}
