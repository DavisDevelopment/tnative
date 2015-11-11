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
}
