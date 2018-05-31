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

class StreamInput<T> extends EventDispatcher {
    /* Constructor Function */
    public function new(o: SIOptions<T>):Void {
        super();

        /* register [this]'s signals */
        addSignals([
            'initialized',
            'readable',
            'data',
            'end',
            'close',
            'error'
        ]);

        /* initialize internal state */
        _ended = false;
        _closed = false;
        _paused = true;
        _allocated = [true, true, true];

        /* set [opts] field, our options/implementation details */
        opts = o;

        /* create internal buffer */
        b = new DefaultStreamInternalBuffer();

        /* create 'pusher' object */
        pusher = {
            next: (v -> _msg(Next(v))),
            error: (e -> _msg(Error(e))),
            done: () -> _msg(Done),
            _stream: this
        };

        if (opts.init != null) {
            opts.init(pusher, function(?error) {
                if (error != null) {
                    pusher.error( error );
                }
                else {
                    _read();
                }
            });
        }
        else {
            _read();
        }

        _init(function(?error) {
            if (error != null) {
                pusher.error( error );
            }
            else {
                _scheduleRead();
            }
        });
    }

/* === Instance Methods === */

    /**
      initialize [this] Stream
     **/
    function _init(done: VoidCb):Void {
        /**
          wrap [done] in our long, ugly, complicated co-callback
         **/
        done = done.wrap(function(_, ?error) {
            if (error != null) {
                _raise( error );
            }
            else {
                _started = true;
                _opened = true;

                addSignal('afterInit');
                _event('initialized', this).then(function() {
                    _event('afterInit', this).then(function() {
                        removeSignal('afterInit');
                    }, _.raise());
                }, _.raise());

                _( error );
            }
        });

        if (opts.init != null) {
            opts.init(pusher, done);
        }
        else {
            done();
        }
    }

    /**
      method used internally to 'read' data into internal buffer
     **/
    private function _read(?len: Int):Void {
        if (opts.read != null) {
            opts.read(pusher, len);
        }
        else {
            throw 'Error: No "_read" implementation given';
        }
    }

    /**
      method used internally to destroy [this] stream
     **/
    private function _destroy(err:Null<Dynamic>, callback:VoidCb):Void {
        if (opts.destroy != null) {
            opts.destroy( callback );
        }
        else {
            callback( err );
        }
    }

    /**
      raise an error on [this]
     **/
    function raise(error: Dynamic) {
        if (!(_ended || _closed)) {
            _raise( error );
        }
        else {
            throw error;
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
    private function _end(err:Null<Dynamic>, done:VoidCb):Bool {
        _ended = true;
        _destroy(err, function(?error) {
            _event('end', error);
            if (error != null) {
                //_raise( error );
                done( error );
            }
            else {
                _close( done );
            }
        });
        return _ended;
    }

    /**
      end [this] stream
     **/
    function end(?done: VoidCb) {
        if ( !_ended ) {
            done = done.nn();
            _end(null, done);
        }
    }

    /**
      shut down all stream-related operations, closing out this stream
     **/
    private function _close(done: VoidCb):Void {
        _event('close', null)
        .then(function() {
            _closed = true;
            defer(function() {
                _dispose( done );
            });
        }, done.raise());
    }

    /**
      delete and/or nullify memory-eating properties
     **/
    private function _dispose(done: VoidCb):Void {
        this._sigs.pairs().iter(function(t) {
            _sigs[t.left].clear();
            t.right = null;
            _sigs.remove( t.left );

            trace('deleted "${t.left}" event');
        });
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
    public function onReadable(f:Void->Void, once:Bool=false):Void {
        on('readable', untyped f, once);
    }

    public function onData(f: T->Void, once:Bool=false):Void {
        on('data', f, once);
    }

    public function onError(f: Dynamic->Void, once:Bool=false):Void {
        on('error', f, once);
    }

    public function onEnd(f: Void->Void, once:Bool=false):Void {
        on('end', untyped f, once);
    }

    public function onClose(f:?Dynamic->Void, once:Bool=false):Void {
        on('close', untyped f, once);
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
                raise( error );

            case Done:
                end();
        }
        return true;
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
            return true;
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

    /* whether [this] has started */
    private var _started: Bool;
    private var _opened: Bool;

    /* whether [this] has ended */
    private var _ended: Bool;

    /* whether [this] has been closed entirely */
    private var _closed: Bool;

    /**
      whether (and to what degree) [this] is still allocated and intact in-memory
      --
      $0: [_destroy] has not been run, or has failed
      $1: [_end] has not been run, or has failed
      $2: [_dispose] has not been run, or has failed
     **/
    private var _allocated:Array<Bool>;

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
    ?init: StreamInputPusher<T>->VoidCb->Void,
    ?read: StreamInputPusher<T>->Null<Int>->Void,
    ?destroy: VoidCb->Void
}

typedef StreamInputPusher<T> = {
    next: T->Bool,
    error: Dynamic->Bool,
    done: Void->Bool,

    _stream: StreamInput<T>
};
