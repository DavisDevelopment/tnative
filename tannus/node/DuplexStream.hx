package tannus.node;

import tannus.async.*;
import haxe.extern.EitherType;

import tannus.node.Buffer;
import tannus.node.EventEmitter;
import tannus.node.WritableStream;
import tannus.node.ReadableStream;
import haxe.Constraints.Function;

@:jsRequire('stream', 'Duplex')
extern class DuplexStream <I, O> extends EventEmitter {
    function new(?options: DuplexStreamOptions):Void;
	/* write some data to [this] Stream */
	@:overload(function(chunk:O, ?cb:Function):Void {})
	@:overload(function(chunk:O, ?enc:String):Void {})
	function write(chunk:O, ?enc:String, ?cb:Function):Void;

	function cork():Void;
	function uncork():Void;
	function setDefaultEncoding(enc : String):Void;

	@:overload(function(chunk:O, ?cb:Function):Void {})
	@:overload(function(chunk:O, ?enc:String):Void {})
	@:overload(function(cb:Function):Void {})
	function end(?chunk:O, ?encoding:String, ?cb:Function):Void;

/* === Implementation === */

    function _write(chunk:O, encoding:String, callback:VoidCb):Void;
    function _writev(chunks:Array<{chunk:O, encoding:String}>, callback:VoidCb):Void;
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

	inline function onPipe<T:EitherType<Readable,Duplex>>(f : T -> Void):Void on('pipe', f);
	inline function onUnpipe<T:EitherType<Readable,Duplex>>(f : T -> Void):Void on('unpipe', f);

	function read(?size : Int):Null<I>;
	function setEncoding(enc : String):Void;
	function resume():DuplexStream<I, O>;
	function pause():DuplexStream<I, O>;
	function isPaused():Bool;
	function pipe<Target:EitherType<Writable,Duplex>>(dest:Target, ?opts:{end:Bool}):Void;
	function unpipe<Target:EitherType<Writable,Duplex>>(?dest : Target):Void;
	function unshift(chunk : I):Void;
	function destroy(?error: Dynamic):Void;
	
	var readableHighWaterMark: Int;
	var readableLength: Int;

/* === implementation === */

    @:noCompletion function push(chunk:I, ?encoding:String):Bool;
    @:noCompletion function _read(?size: Int):Void;
    @:noCompletion function _destroy(error:Null<Dynamic>, callback:VoidCb):Void;

/* === Event Methods === */

    //inline function onOpen(f : Void->Void):Void on('open', f);
    inline function onData(f : I->Void):Void on('data', f);
    inline function onceData(f : I->Void):Void once('data', f);
    inline function onEnd(f : Void->Void):Void on('end', f);
    inline function onceEnd(f : Void->Void):Void once('end', f);
    inline function onReadable(f : Void->Void):Void on('readable', f);
    inline function onceReadable(f : Void->Void):Void once('readable', f);
}

typedef DuplexStreamOptions = {
    >ReadableStreamOptions,
    >WritableStreamOptions,

    ?allowHalfOpen: Bool,
    ?readableObjectMode: Bool,
    ?writableObjectMode: Bool,
    ?readableHighWaterMark: Int,
    ?writableHighWaterMark: Int
};

typedef SymmetricalDuplexStream<T> = DuplexStream <T, T>;
