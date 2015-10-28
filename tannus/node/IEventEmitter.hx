package tannus.node;

import haxe.Constraints.Function;

interface IEventEmitter {
	function addListener(event:String, listener:Function):Void;
	function on(event:String, listener:Function):Void;
	function once(event:String, listener:Function):Void;
	function removeListener(event:String, listener:Function):Void;
	function removeAllListeners(?event : String):Void;
	function emit(event:String, data:Dynamic):Void;
}
