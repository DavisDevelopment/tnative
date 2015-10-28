package tannus.node;

import tannus.node.Buffer;
import tannus.node.EventEmitter;
import tannus.node.WritableStream;
import haxe.Constraints.Function;

@:jsRequire('stream', 'Duplex')
extern class Duplex extends EventEmitter {
	function read(?size : Int):Null<Buffer>;

	function setEncoding(enc : String):Void;

	function resume():ReadableStream;

	function pause():ReadableStream;

	function isPaused():Bool;

	function pipe(dest:WritableStream, opts:{end:Bool}):Void;

	function unpipe(?dest : WritableStream):Void;

	function unshift(chunk : Buffer):Void;

	function write(chunk:Buffer, ?enc:String, ?cb:Function):Void;

	function cork():Void;

	function uncork():Void;

	function setDefaultEncoding(enc : String):Void;

	function end(?chunk:Buffer, ?encoding:String, ?cb:Function):Void;
}
