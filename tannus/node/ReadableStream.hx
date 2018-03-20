package tannus.node;

import tannus.async.*;

import haxe.Constraints.Function;

import tannus.node.Buffer;
import tannus.node.EventEmitter;
import tannus.node.WritableStream;

@:jsRequire('stream', 'Readable')
extern class ReadableStream <Data> extends EventEmitter {
    function new(?options: ReadableStreamOptions):Void;

	function read(?size : Int):Null<Data>;
	function setEncoding(enc : String):Void;
	function resume():ReadableStream<Data>;
	function pause():ReadableStream<Data>;
	function isPaused():Bool;
	function pipe(dest:Writable, ?opts:{end:Bool}):Void;
	function unpipe(?dest : Writable):Void;
	function unshift(chunk : Data):Void;
	function destroy(?error: Dynamic):Void;
	
	var readableHighWaterMark: Int;
	var readableLength: Int;

/* === implementation === */

    @:noCompletion function push(chunk:Data, ?encoding:String):Bool;
    @:noCompletion function _read(?size: Int):Void;
    @:noCompletion function _destroy(error:Null<Dynamic>, callback:VoidCb):Void;

/* === Event Methods === */

    //inline function onOpen(f : Void->Void):Void on('open', f);
    inline function onClose(f : Void->Void):Void on('close', f);
    inline function onData(f : Data->Void):Void on('data', f);
    inline function onEnd(f : Void->Void):Void on('end', f);
    inline function onError(f : Dynamic->Void):Void on('error', f);
    inline function onReadable(f : Void->Void):Void on('readable', f);
}

typedef ReadableStreamOptions = {
    ?highWaterMark: Int,
    ?encoding: String,
    ?objectMode: Bool,
    ?read: Function,
    ?destroy: Function
};
