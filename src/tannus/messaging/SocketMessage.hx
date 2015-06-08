package tannus.messaging;

import tannus.messaging.MessageType;
import tannus.ds.Object;
import tannus.ds.Memory;

class SocketMessage {
	/* Constructor Function */
	public function new(typ:MessageType, chann:String, dat:Object):Void {
		channel = chann;
		type = typ;
		data = dat;
		peer = null;
		id = Memory.uniqueIdString('msg-');
		sender = '';
	}

/* === Instance Fields === */

	public var id:String;
	public var sender:String;
	public var channel:String;
	public var type:MessageType;
	public var data:Object;
	public var peer:Null<String>;
	public var reply:Null<Dynamic->Void>;
}
