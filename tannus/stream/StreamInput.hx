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

class StreamInput<T> extends EventDispatcher {
    /* Constructor Function */
    public function new(o: SIOptions<T>):Void {
        super();

        addSignals(['readable', 'end', 'close', 'error', 'data']);
        b = new DefaultStreamInternalBuffer();
        _ended = false;
        pusher = {
            next: (v -> _msg(Next(v))),
            error: (e -> _msg(Error(e))),
            done: () -> _msg(Done)
        };
        opts = o;
        _read();
    }

/* === Instance Methods === */

    private function _read(?len: Int):Void {
        if (opts.read != null) {
            opts.read( pusher );
        }
    }

    public function read(?len: Int):Null<T> {
        if (hasDataAvailable()) {
            return b.pop();
        }
        else if ( _ended ) {
            throw EndOfInput;
            return null;
        }
        else {
            //defer(_read.bind(len));
            throw StreamInputErrorType.NoDataAvailable;
            return null;
        }
    }

    public function onReadable(f: Void->Void):Void {
        on('readable', untyped f);
    }

    public function hasDataAvailable():Bool {
        return (b.state.match(BSDataAvailable) && b.length() > 0);
    }

    public function hasEnded():Bool return _ended;

    private function _msg(message: StreamMessage<T>):Bool {
        switch ( message ) {
            case Next( value ):
                return push( value );

            case Error( error ):
                return _raise( error );

            case Done:
                return _end();
        }
    }

    private function _bufferStateChanged(x:StreamBufferState<T>, y:StreamBufferState<T>):Void {
        switch ([x, y]) {
            case [BSEmpty, BSDataAvailable]:
                //defer(dispatch.bind('readable', null));
                _event('readable', null);

            //case [BSDataAvailable, BSHighWater]:
                //dispatch();
            default:
                return ;
        }
    }

    private function push(value: T):Bool {
        var hasData:Bool = false;
        if (b.state.match(BSDataAvailable)) {
            hasData = true;
        }
        var ret = _fbuf(b -> b.push(value));
        if ( hasData ) {
            //defer(dispatch.bind('data', value));
            _event('data', value);
        }
        return ret;
    }

    private function pop():T {
        if (b.state.match(BSEmpty)) {
            throw StreamInputErrorType.NoDataAvailable;
        }
        else {
            return _fbuf(b -> b.pop());
        }
    }

    private function _raise(error: Dynamic):Bool {
        _event('error', error);
        return true;
    }

    private function _end():Bool {
        _ended = true;
        _event('end', null);
        return _ended;
    }

    private function _event<T>(name:String, data:T):Void {
        dispatch(name, data);
    }
    
    @:access( edis.streams.io.StreamInternalBuffer )
    private function _fbuf<A>(f:StreamInternalBuffer<T>->A):A {
        var tmp = b.state;
        var ret = f( b );
        if (!tmp.equals(b.state)) {
            _bufferStateChanged(tmp, b.state);
        }
        return ret;
    }

/* === Instance Fields === */

    private var b: StreamInternalBuffer<T>;
    private var _ended: Bool;
    private var pusher: StreamInputPusher<T>;
    private var opts: SIOptions<T>;
}

enum StreamInputErrorType<T> {
    //ReadClosedInput;
    EndOfInput;
    NoDataAvailable;
    NoImplementationProvided;
}

typedef StreamInputPusher<T> = {
    next: T->Bool,
    error: Dynamic->Bool,
    done: Void->Bool
};

typedef SIOptions<T> = {
    ?read: StreamInputPusher<T>->Void,
    ?destroy: VoidCb->Void
}
