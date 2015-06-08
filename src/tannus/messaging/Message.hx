package tannus.messaging;

import tannus.ds.Memory;
import tannus.ds.Object;
import tannus.io.Ptr;
import tannus.io.Signal;

import tannus.messaging.Messager;
import tannus.messaging.SafeMessage;

@:access(tannus.messaging.Messager)
class Message {
	/* Constructor Function */
	public function new(sock:Messager, dat:Object):Void {
		id = Memory.uniqueIdString('msg-');
		sender = sock;
		data = dat;
		type = Normal;
		channel = '';
	}

/* === Instance Methods === */

	/**
	  * Create and Return a transport-safe version of [this] Message
	  */
	public function safe():SafeMessage {
		return new SafeMessage({
			'id' : id,
			'sender_id' : sender.id,
			'type' : type,
			'channel' : channel,
			'data' : data
		});
	}

	/**
	  * Reply to [this] Message
	  */
	public function reply(data : Dynamic):Void {
		var repl:Message = new Message(sender, data);
		repl.type = Reply;
		repl.id = id;

		sender.sendToPeer( repl );
	}

/* === Class Methods === */

	/**
	  * Create a Message object from a SafeMessage
	  */
	public static function fromSafe(sock:Messager, saf:SafeMessage):Message {
		var m = new Message(sock, saf.data);
		m.id = saf.id;
		m.sender_id = saf.sender_id;
		m.type = saf.type;
		m.channel = saf.channel;
		return m;
	}

/* === Instance Fields === */
	
	public var id : String;
	public var sender_id : String;
	public var source_id : Null<String>;
	public var data : Object;
	public var channel : String;
	public var type : MessageType;

	private var sender : Messager;
}
