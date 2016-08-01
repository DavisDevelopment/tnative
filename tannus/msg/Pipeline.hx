package tannus.msg;

import tannus.ds.Maybe;

interface Pipeline {
	function close():Void;
	function sendMessage(message : Message<Dynamic>):Void;
	function send(action:String, data:Dynamic, ?onresponse:Dynamic->Void):Void;
	function on<T>(action:String, handler:Message<T>->Void):Void;
	function receive(message : Message<Dynamic>):Void;
	
	function createMessage():Message<Dynamic>;
	function createChannel(name : String):Channel;
	function openChannel(name : String):Channel;
	function closeChannel(name : String):Void;
	function hasChannel(name : String):Bool;
	function channel(name : String):Channel;

	function getContext():SocketContext<Socket>;
	function getPipe():Pipe<Message<Dynamic>>;
	function getAddress():Address;
	function getPeerAddress():Maybe<Address>;

/* === Fields === */

	//var address : Address;
	var router : PipelineRouter;
}
