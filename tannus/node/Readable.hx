package tannus.node;

import tannus.node.Buffer;
import tannus.node.IEventEmitter;

interface Readable extends IEventEmitter {
	function read(?size : Int):Null<Buffer>;

	function setEncoding(enc : String):Void;

	function resume():Readable;

	function pause():Readable;

	function isPaused():Bool;

	function pipe(dest:Writable, opts:{end:Bool}):Void;

	function unpipe(?dest : Writable):Void;

	function unshift(chunk : Buffer):Void;
}
