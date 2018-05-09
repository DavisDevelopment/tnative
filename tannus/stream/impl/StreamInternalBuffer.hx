package tannus.stream.impl;

import tannus.io.*;
import tannus.ds.*;
import tannus.async.*;

import Slambda.fn;

import tannus.stream.StreamMessage;
import tannus.stream.StreamMessage as Msg;

using Lambda;
using tannus.ds.ArrayTools;
using StringTools;
using tannus.ds.StringUtils;
using tannus.FunctionTools;

interface StreamInternalBuffer<T> {
    //var stream: StreamAlgo<T, Dynamic>;
    var state: StreamBufferState<T>;

    function push(value:T, ?type:String):Bool;
    function pop():T;
    function length():Int;
    function recommendedHighWaterMark():Int;
}

/**
  purpose of class
 **/
class DefaultStreamInternalBuffer<T> implements StreamInternalBuffer<T> {
    /* Constructor Function */
    public function new():Void {
        a = [];
        //stream = s;
        state = BSEmpty;
    }

/* === Instance Methods === */

    public function push(value:T, ?type:String):Bool {
        a.push( value );
        update_state();
        return !state.match(BSHighWater);
    }

    public function pop():T {
        var ret = a.shift();
        update_state();
        return ret;
    }

    public function length():Int return a.length;
    public function recommendedHighWaterMark():Int return 16;

    /**
      update this's [state] field
     **/
    private function update_state():Void {
        var len = length();
        if (len > 0) {
            state = BSDataAvailable;
            if (len >= recommendedHighWaterMark()) {
                state = BSHighWater;
            }
        }
        else if (len == 0) {
            state = BSEmpty;
        }
    }

/* === Computed Instance Fields === */
/* === Instance Fields === */

    //public var stream: StreamAlgo<T, Dynamic>;
    public var state: StreamBufferState<T>;
    
    private var a: Array<T>;
}

enum StreamBufferState<T> {
    BSEmpty;
    BSHighWater;
    BSDataAvailable;
}
