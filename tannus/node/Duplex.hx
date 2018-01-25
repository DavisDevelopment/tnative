package tannus.node;

import tannus.async.*;
import haxe.extern.EitherType;

import tannus.node.Buffer;
import tannus.node.EventEmitter;
import tannus.node.WritableStream;
import haxe.Constraints.Function;

@:jsRequire('stream', 'Duplex')
extern class Duplex extends EventEmitter {
	/* write some data to [this] Stream */
	@:overload(function(chunk:Buffer, ?cb:Function):Void {})
	@:overload(function(chunk:Buffer, ?enc:String):Void {})
	function write(chunk:Buffer, ?enc:String, ?cb:Function):Void;

	function cork():Void;
	function uncork():Void;
	function setDefaultEncoding(enc : String):Void;

	@:overload(function(chunk:Buffer, ?cb:Function):Void {})
	@:overload(function(chunk:Buffer, ?enc:String):Void {})
	@:overload(function(cb:Function):Void {})
	function end(?chunk:Buffer, ?encoding:String, ?cb:Function):Void;

/* === Implementation === */

    function _write(chunk:Buffer, encoding:String, callback:VoidCb):Void;
    function _writev(chunks:Array<{chunk:Buffer,encoding:String}>, callback:VoidCb):Void;
    //function _destroy(error:Null<Dynamic>, callback:VoidCb):Void;
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

	inline function onPipe(f : EitherType<ReadableStream,Duplex>->Void):Void on('pipe', f);
	inline function onUnpipe(f : EitherType<ReadableStream,Duplex>->Void):Void on('unpipe', f);

	function read(?size : Int):Null<Buffer>;
	function setEncoding(enc : String):Void;
	function resume():Duplex;
	function pause():Duplex;
	function isPaused():Bool;
	function pipe(dest:EitherType<WritableStream, Duplex>, ?opts:{end:Bool}):Void;
	function unpipe(?dest : WritableStream):Void;
	function unshift(chunk : Buffer):Void;
	function destroy(?error: Dynamic):Void;
	
	var readableHighWaterMark: Int;
	var readableLength: Int;

/* === implementation === */

    @:noCompletion function push(chunk:Buffer, ?encoding:String):Bool;
    @:noCompletion function _read(?size: Int):Void;
    @:noCompletion function _destroy(error:Null<Dynamic>, callback:VoidCb):Void;

/* === Event Methods === */

    //inline function onOpen(f : Void->Void):Void on('open', f);
    inline function onData(f : Buffer->Void):Void on('data', f);
    inline function onceData(f : Buffer->Void):Void once('data', f);
    inline function onEnd(f : Void->Void):Void on('end', f);
    inline function onceEnd(f : Void->Void):Void once('end', f);
    inline function onReadable(f : Void->Void):Void on('readable', f);
    inline function onceReadable(f : Void->Void):Void once('readable', f);
}
