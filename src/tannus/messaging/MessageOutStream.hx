package tannus.messaging;

import tannus.messaging.Messager in Socket;
import tannus.messaging.Message;
import tannus.messaging.StreamMessage;

import tannus.ds.Object;
import tannus.io.Signal;
import tannus.io.EventDispatcher;

class MessageOutStream<T> extends EventDispatcher {
	/* Constructor Function */
	public function new(messager:Socket, nam:String):Void {
		super();

		owner = messager;
		name = nam;

		addSignal('open');
	}

/* === Instance Methods === */

	/**
	  * Provides the interface (Message object) by which data is streamed to the peer
	  */
	private function open(data:Object, wf:StreamMessage<T>->Void):Void {
		_write = wf;

		dispatch('open', data);
	}

	/**
	  * Write some data
	  */
	public function write(v : T):Void {
		_write(SData( v ));
	}

	/**
	  * End the stream
	  */
	public function close():Void {
		_write( SClose );
	}

/* === Instance Fields === */

	private var owner : Socket;
	private var name : String;

	private var _write : StreamMessage<T> -> Void;
}
