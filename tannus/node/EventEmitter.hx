package tannus.node;

import haxe.Constraints.Function;
import haxe.extern.Rest;

@:jsRequire('events', 'EventEmitter')
extern class EventEmitter {
	/* Listen for Events of [this] Emitter */
	function addListener(event:String, listener:Function):EventEmitter;
	function on(event:String, listener:Function):EventEmitter;
	function once(event:String, listener:Function):EventEmitter;

	/* Stop Listening */
	function removeListener(event:String, listener:Function):EventEmitter;
	function removeAllListeners(?event:String):EventEmitter;

	/* Emit an Event */
	function emit(event:String, args:Rest<Dynamic>):Bool;
}
