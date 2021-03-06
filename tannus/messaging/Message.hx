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
		meta = {};
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
			'type' : haxe.Serializer.run(type),
			'channel' : channel,
		       	'meta' : haxe.Serializer.run(meta),
			'data' : haxe.Serializer.run(data)
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
		var m = new Message(sock, haxe.Unserializer.run(cast saf.data));
		m.id = saf.id;
		m.sender_id = saf.sender_id;
		m.type = haxe.Unserializer.run(saf.type);
		m.channel = saf.channel;
		m.meta = saf.meta;
		return m;
	}

/* === Instance Fields === */
	
	public var id : String;
	public var sender_id : String;
	public var source_id : Null<String>;
	public var channel : String;
	public var type : MessageType;

	public var meta : Object;
	public var data : Object;

	private var sender : Messager;
}
