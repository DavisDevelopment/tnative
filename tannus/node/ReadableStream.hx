package tannus.node;

import tannus.node.Buffer;
import tannus.node.EventEmitter;
import tannus.node.WritableStream;

@:jsRequire('stream', 'Readable')
extern class ReadableStream extends EventEmitter {
	function read(?size : Int):Null<Buffer>;

	function setEncoding(enc : String):Void;

	function resume():ReadableStream;

	function pause():ReadableStream;

	function isPaused():Bool;

	function pipe(dest:WritableStream, ?opts:{end:Bool}):Void;

	function unpipe(?dest : WritableStream):Void;

	function unshift(chunk : Buffer):Void;

/* === Event Methods === */

    inline function onOpen(f : Void->Void):Void on('open', f);
    inline function onClose(f : Void->Void):Void on('close', f);
    inline function onData(f : Dynamic->Void):Void on('data', f);
    inline function onEnd(f : Void->Void):Void on('end', f);
    inline function onError(f : Dynamic->Void):Void on('error', f);
    inline function onReadable(f : Void->Void):Void on('readable', f);
}
