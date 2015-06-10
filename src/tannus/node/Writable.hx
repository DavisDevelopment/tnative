package tannus.node;

import tannus.node.Buffer;
import tannus.node.IEventEmitter;
import haxe.Constraints.Function;

interface Writable extends IEventEmitter {
	/* write some data to [this] Stream */
	function write(chunk:Buffer, ?enc:String, ?cb:Function):Void;

	function cork():Void;
	function uncork():Void;
	function setDefaultEncoding(enc : String):Void;

	function end(?chunk:Buffer, ?encoding:String, ?cb:Function):Void;
}
