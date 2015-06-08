package tannus.messaging;

import tannus.messaging.Message;
import tannus.messaging.MessageType;
import tannus.io.Ptr;
import tannus.io.Signal;
import tannus.ds.Memory;
import tannus.ds.Object;

class Messager {
	/* Constructor Function */
	public function new():Void {
		id = Memory.uniqueIdString('messenger-');
		incoming = new Signal();
		channels = new Map();
		awaitingReply = new Map();
	}

/* === Instance Methods === */

	/**
	  * Send a Message
	  */
	private function sendToPeer(msg : Message):Void {
		throw 'Not Implemented!';
	}

	/**
	  * Receive a Message
	  */
	private function receiveFromPeer(msg : Message):Void {
		throw 'Not Implemented!';
	}

	/**
	  * Send some data
	  */
	public function send(type:String, data:Object, ?onreply:Object->Void):Void { 
		var msg:Message = new Message(this, data);
		msg.type = Normal;
		msg.channel = type;
		
		if (onreply != null) {
			awaitingReply[msg.id] = onreply;
		}

		sendToPeer( msg );
	}

	/**
	  * Obtain a reference to the Signal for a given channel
	  */
	private function chanSig(chan : String):Signal<Message> {
		if (!channels.exists(chan)) 
			channels[chan] = new Signal();
		return channels[chan];
	}

	/**
	  * Listen for Messages on a particular Channel
	  */
	public function on(channel:String, cb:Message->Void):Void {
		var sig = chanSig(channel);
		sig.on( cb );
	}

	/**
	  * Listen for one Message on a Channel
	  */
	public function once(channel:String, cb:Message->Void):Void {
		chanSig(channel).once( cb );
	}

	/**
	  * Stop listening on a Channel
	  */
	public function off(chan:String, cb:Message->Void):Void {
		chanSig(chan).off( cb );
	}

/* === Instance Fields === */

	/* The unique identifier for [this] Messenger */
	public var id : String;

	/* The Signal Fired when a new Message is received */
	public var incoming : Signal<Message>;

	/* Channel Registry */
	public var channels : Map<String, Signal<Message>>;

	/* The Queue of Messages which may receive a reply */
	private var awaitingReply : Map<String, Dynamic->Void>;
}
