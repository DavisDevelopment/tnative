package tannus.node;

import tannus.node.Duplex;
import tannus.node.Buffer;

@:jsRequire('net', 'Socket')
extern class Socket extends Duplex {
	function new(?options : SockOpts):Void;

	var remoteAddress:String;
	var remotePort:Int;
	var bufferSize:Int;
	var bytesRead:Int;
	var bytesWritten:Int;

	@:overload(function(path:String, ?cb:Void->Void):Void {})
	function connect(port:Int, ?host:String, ?cb:Void->Void):Void;
	function setSecure():Void;
	function destroy():Void;
	function setKeepAlive(enable:Bool, ?delay:Int):Void;
	function address():{address:String,port:Int};
}

private typedef SockOpts = {
	var fd : Null<Dynamic>;
	var allowHalfOpen : Bool;
	var readable : Bool;
	var writable : Bool;
};
