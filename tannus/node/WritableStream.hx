package tannus.node;

import tannus.node.Buffer;
import tannus.node.EventEmitter;

import tannus.async.*;
import haxe.Constraints.Function;

@:jsRequire('stream', 'Writable')
extern class WritableStream<Data> extends EventEmitter {
    /* Constructor Function */
    function new(?options: WritableStreamOptions):Void;

	/* write some data to [this] Stream */
	@:overload(function(chunk:Data, ?cb:Function):Void {})
	@:overload(function(chunk:Data, ?enc:String):Void {})
	function write(chunk:Data, ?enc:String, ?cb:Function):Void;

	function cork():Void;
	function uncork():Void;
	function setDefaultEncoding(enc : String):Void;
	function destroy(?error: Dynamic):Void;

	@:overload(function(chunk:Data, ?cb:Function):Void {})
	@:overload(function(chunk:Data, ?enc:String):Void {})
	@:overload(function(cb:Function):Void {})
	function end(?chunk:Data, ?encoding:String, ?cb:Function):Void;

	public var writableHighWaterMark: Int;
	public var writableLength: Int;

/* === Implementation === */

    function _write(chunk:Data, encoding:String, callback:VoidCb):Void;
    function _writev(chunks:Array<{chunk:Data,encoding:String}>, callback:VoidCb):Void;
    function _destroy(error:Null<Dynamic>, callback:VoidCb):Void;
    function _final(callback: VoidCb):Void;

/* === Event Methods === */

	inline function onClose(f : Void->Void):Void on('close', f);
	inline function onceClose(f : Void->Void):Void once('close', f);
	inline function onDrain(f : Void->Void):Void on('drain', f);
	inline function onceDrain(f : Void->Void):Void once('drain', f);
	inline function onError(f : Null<Dynamic>->Void):Void on('error', f);
	inline function onceError(f : Null<Dynamic>->Void):Void once('error', f);
	inline function onFinish(f : Void->Void):Void on('finish', f);
	inline function onceFinish(f : Void->Void):Void once('finish', f);
	inline function onPipe(f : Readable->Void):Void on('pipe', f);
	inline function onUnpipe(f : Readable->Void):Void on('unpipe', f);
}

typedef WritableStreamOptions = {
    ?highWaterMark: Int,
    ?decodeStrings: String,
    ?objectMode: Bool,
    ?encoding: String,
    ?write: Function,
    ?writev: Function,
    ?destroy: Function
    //?final: Function
};

