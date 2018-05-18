package tannus.stream;

import tannus.io.*;
import tannus.ds.*;
import tannus.async.*;

class EventLoop {
#if js
    @:native('q')
    private static var _qpush:Null<(Void->Void)->Void> = null;
    public static function queue(f: Void->Void):Void {
        if (_qpush == null) {
            _qpush = (
            #if node
                untyped __js__('(setImmediate || process.nextTick)');
            #else
                untyped __js__('(setImmediate || (setTimeout && x => setTimeout(x, 0)))');
            #end
            );
        }
        return _qpush( f );
    }
#else
    public static inline function queue(f: Void->Void):Void {
        throw 'Error: No implementation of [queue] on this platform';
    }
#end
}
