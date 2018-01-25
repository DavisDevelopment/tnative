package tannus.node;

import tannus.node.Buffer;
import tannus.node.EventEmitter;

import tannus.async.*;
import haxe.Constraints.Function;

@:jsRequire('stream', 'Writable')
extern class WritableStream extends EventEmitter {
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
	inline function onPipe(f : ReadableStream->Void):Void on('pipe', f);
	inline function onUnpipe(f : ReadableStream->Void):Void on('unpipe', f);
}
