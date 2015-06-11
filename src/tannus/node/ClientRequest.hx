package tannus.node;

import haxe.Constraints.Function;
import haxe.extern.EitherType;
import haxe.extern.Rest;

import tannus.node.Buffer;
import tannus.ds.Object;

@:jsRequire('http', 'ClientRequest')
extern class ClientRequest extends EventEmitter {
/* === Instance Methods === */
	function flushHeaders():Void;

	@:overload(function(chunk:Buffer, ?cb:Function):Void{})
	function write(chunk:Buffer, ?encoding:String, ?callback:Function):Void;

	@:overload(function(?chunk:Buffer, ?cb:Function):Void{})
	function end(?data:Buffer, ?encoding:String, ?callback:Function):Void;

	function abort():Void;

	function setTimeout(ms:Int, ?cb:Function):Void;

	function setNoDelay(?nodelay:Bool):Void;
}
