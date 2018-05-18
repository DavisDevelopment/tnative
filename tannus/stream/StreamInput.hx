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
        addSignals([
            'readable',
            'data',
            'end',
            'close',
            'error'
        ]);

        _ended = false;
        _paused = true;

        opts = o;

        b = new DefaultStreamInternalBuffer();
        pusher = {
            next: (v -> _msg(Next(v))),
            error: (e -> _msg(Error(e))),
            done: () -> _msg(Done)
        };

        _read();
    }

/* === Instance Methods === */

    /**
      method used internally to 'read' data into internal buffer
     **/
    private function _read(?len: Int):Void {
        if (opts.read != null) {
            opts.read( pusher );
        }
        else {
            throw 'Error: No "_read" implementation given';
        }
    }

    /**
      method used internally to destroy [this] stream
     **/
    private function _destroy(err:Null<Dynamic>, callback:VoidCb):Void {
        callback( err );
    }

    /**
      read some data from [this] Stream
     **/
    public function read(?len: Int):Null<T> {
        if (hasDataAvailable()) {
            return b.pop();
        }
        else if ( _ended ) {
            throw EndOfInput;
        }
        else {
            _scheduleRead( len );

            if (isPaused()) {
                throw StreamInputErrorType.NoDataAvailable;
            }
            else {
                return null;
            }
        }
        return null;
    }

    /**
      schedule the next call to [_read]
     **/
    private function _scheduleRead(?len: Int):Void {
        defer(function() {
            _read( len );
        });
    }

    /**
      listen for 'readable' event
     **/
    public function onReadable(f: Void->Void):Void {
        on('readable', untyped f);
    }

    public function onData(f: T->Void):Void {
        on('data', f);
    }

    public function onError(f: Dynamic->Void):Void {
        on('error', f);
    }

    public function onEnd(f: Void->Void):Void {
        on('end', untyped f);
    }

    public function onClose(f: ?Dynamic->Void):Void {
        on('close', untyped f);
    }

    public function hasDataAvailable():Bool {
        return (b.state.match(BSDataAvailable) && b.length() > 0);
    }

    /**
      check whether [this] stream has ended
     **/
    public function hasEnded():Bool {
        return _ended;
    }

    public function pause():Void {
        _paused = true;
    }

    public function unpause():Void {
        _paused = false;
    }

    public function isPaused():Bool {
        return _paused;
    }

    public function isFlowing():Bool {
        return !isPaused();
    }

    /**
      handle incoming StreamMessage
     **/
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

    /**
      handle a change made to the buffer's state
     **/
    private function _bufferStateChanged(x:StreamBufferState<T>, y:StreamBufferState<T>):Void {
        switch ([x, y]) {
            // went from empty to readable
            case [BSEmpty, BSDataAvailable]:
                // dispatch 'readable' event
                _event('readable', null);

            default:
                return ;
        }
    }

    /**
      'push' data onto [this]'s buffer
     **/
    private function push(value: T):Bool {
        // whether [this]'s buffer has data present on it
        var hasData:Bool = b.state.match(BSDataAvailable);

        // if in 'paused' mode
        if (isPaused()) {
            // dispatch 'data' event
            _event('data', value);

            return _fbuf(b -> b.push( value ));
        }
        else if (isFlowing()) {
            _event('data', value);
        }
        else {
            return false;
        }
    }

    /**
      'pop' data off of the buffer and return it
     **/
    private function pop():T {
        if (b.state.match( BSEmpty )) {
            throw StreamInputErrorType.NoDataAvailable;
        }
        else {
            return _fbuf(b -> b.pop());
        }
    }

    /**
      raise an error on [this] stream
     **/
    private function _raise(error: Dynamic):Bool {
        _event('error', error);
        return true;
    }

    /**
      mark the end of [this] stream
     **/
    private function _end():Bool {
        _ended = true;
        _event('end', null);
        return _ended;
    }

    /**
      dispatch an event
     **/
    private function _event<T>(name:String, data:T):Void {
        defer(dispatch.bind(name, data));
    }
    
    /**
      invoke [f], observing the changes (if any) made to the buffer's state
     **/
    @:access( edis.streams.io.StreamInternalBuffer )
    private function _fbuf<A>(f:StreamInternalBuffer<T>->A):A {
        var tmp = b.state;
        var ret = f( b );
        if (!tmp.equals(b.state)) {
            _bufferStateChanged(tmp, b.state);
        }
        return ret;
    }

    /**
      enqueue [f] onto the next event-loop cycle
     **/
    private static inline function defer(f: Void->Void):Void {
        return EventLoop.queue( f );
    }

/* === Instance Fields === */

    /* [this]'s internal buffer */
    private var b: StreamInternalBuffer<T>;

    /* [this]'s writer interface */
    private var pusher: StreamInputPusher<T>;

    /* [this]'s provided options */
    private var opts: SIOptions<T>;

    /* whether [this] has ended */
    private var _ended: Bool;

    /* whether [this] is paused */
    private var _paused: Bool;
}

enum StreamInputErrorType<T> {
    //ReadClosedInput;
    EndOfInput;
    NoDataAvailable;
    NoImplementationProvided;
}

typedef SIOptions<T> = {
    ?read: StreamInputPusher<T>->Void,
    ?destroy: VoidCb->Void
}

typedef StreamInputPusher<T> = {
    next: T->Bool,
    error: Dynamic->Bool,
    done: Void->Bool
};
