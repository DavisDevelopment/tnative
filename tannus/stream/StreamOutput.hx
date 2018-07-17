package tannus.stream;

import tannus.io.*;
import tannus.ds.*;
import tannus.async.*;

import Slambda.fn;
import edis.Globals.*;

import tannus.stream.StreamMessage;
import tannus.stream.StreamMessage as Msg;
import tannus.stream.impl.StreamInternalBuffer;

using Lambda;
using tannus.ds.ArrayTools;
using StringTools;
using tannus.ds.StringUtils;
using tannus.FunctionTools;
using tannus.async.Asyncs;
using tannus.ds.MapTools;

class StreamOutput<T> extends EventDispatcher {
    /* Constructor Function */
    public function new(?options: StreamOutputOptions):Void {
        super();
        addSignals([
            'initialized'
        ]);

        if (options == null)
            options = {};
        this.options = fillOptions( options );
        this.buffer = new DefaultStreamInternalBuffer();
        this._started = false;
        this._paused = true;
        this._writing = false;

        init(function(?error) {
            if (error != null) {
                caught( error );
            }
            else {
                //
            }
        });
    }

/* === Instance Methods === */

    /**
      initialize [this] Output
     **/
    function init(done: VoidCb):Void {
        _init(function(?error) {
            if (error != null) {
                done( error );
            }
            else {
                _started = true;
                addSignal('afterInit');
                _event('initialized', this).then(function() {
                    _event('afterInit', this).then(function() {
                        removeSignal('afterInit');
                    }, done.raise());
                }, done.raise());
            }
        });
    }

    /**
      initialize [this] Output
     **/
    function _init(done: VoidCb):Void {
        done();
    }

    /**
      write a value onto [this] output
     **/
    public function put(item:T, ?done:VoidCb):Void {
        done = done.nn();
        if ( _writing ) {
            //TODO
        }
        else if ( _paused ) {
            if (!isHighWater()) {
                _buffer( item );
            }
            else {
                flush(function(?error) {
                    if (error != null) {
                        done( error );
                    }
                    else {
                        put(item, done);
                    }
                });
            }
        }
        else {
            try {
                _put(item, done);
            }
            catch (err: StreamOutputErrorType) {
                switch err {
                    case ErrNotImplemented:
                        _putd([item], done);
                    
                    case _:
                        throw err;
                }
            }
        }
    }

    public function flush(?done: VoidCb):Void {
        done = done.nn();

        var items = buffer.flush();
        _bufferedSize = 0;
        try {
            _putd(items, done);
        }
        catch (err: StreamOutputErrorType) {
            switch err {
                case ErrNotImplemented:
                    [for (item in items) _put.bind(item, _)].series( done );

                case _:
                    throw err;
            }
        }
    }

    /**
      write a value
     **/
    function _put(item:T, done:VoidCb):Void {
        throw StreamOutputErrorType.ErrNotImplemented;
    }

    /**
      write multiple values at the same time
     **/
    function _putd(items:Array<T>, done:VoidCb):Void {
        throw StreamOutputErrorType.ErrNotImplemented;
    }

    /**
      re-buffer some data that was prematurely read from the buffer
     **/
    public function unshift(item: T) {
        _buffer(item, false);
    }

    function fillOptions(o : StreamOutputOptions):StreamOutputOptions {
        if (o.highWaterMark == null) {
            o.highWaterMark = 200;
        }

        return o;
    }

    function caught(error: Dynamic) {
        _error( error );
    }

    function _error(error: Dynamic) {
        throw error;
    }

    /**
      check whether the buffer should continue to be used
     **/
    function isHighWater():Bool {
        return (_bufferedSize >= options.highWaterMark);
    }

    /**
      calculate the size (whatever that means in the given context) of the given item
     **/
    function _itemSize(item: T):Int {
        return 1;
    }

    /**
      add an item to the buffer
     **/
    function _buffer(item:T, end:Bool=true):Int {
        _bufferedSize += _itemSize( item );
        if ( end )
            buffer.push( item );
        else
            buffer.unshift( item );
        return _bufferedSize;
    }

    /**
      pop an item off of the buffer
     **/
    function _unbuffer():Null<T> {
        var item:T = buffer.pop();
        if (item == null) {
            return null;
        }
        else {
            _bufferedSize -= _itemSize( item );
        }
        return item;
    }

    /**
      dispatch an event
     **/
    private function _event<T>(name:String, data:T):VoidPromise {
        return new VoidPromise(function(retern, raise) {
            try {
                defer(function() {
                    try {
                        dispatch(name, data);
                        retern();
                    }
                    catch (err: Dynamic) {
                        raise( err );
                    }
                });
            }
            catch (err: Dynamic) {
                raise( err );
            }
        });
    }

    /**
      enqueue [f] onto the next event-loop cycle
     **/
    private static inline function defer(f: Void->Void):Void {
        return EventLoop.queue( f );
    }

/* === Instance Fields === */

    var buffer: DefaultStreamInternalBuffer<T>;
    var options: StreamOutputOptions;

    var _started: Bool;
    var _paused: Bool;
    var _writing: Bool;
    var _bufferedSize: Int;
}

typedef StreamOutputOptions = {
    ?highWaterMark: Int
};

enum StreamOutputErrorType {
    ErrNotImplemented;
}
