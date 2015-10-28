package tannus.messaging;

import tannus.messaging.Messager in Socket;
import tannus.messaging.Message;
import tannus.messaging.StreamMessage;

import tannus.ds.Object;
import tannus.ds.AsyncStack in Stack;
import tannus.io.Signal;
import tannus.io.EventDispatcher;

class MessageInStream<T> extends EventDispatcher {
	/* Constructor Function */
	public function new(s:Socket, nam:String):Void {
		super();

		owner = s;
		name = nam;
		buf = new Array();
		desired = 0;
		received = new Signal();
		closed = false;

		addSignal('closed');
	}

/* === Instance Methods === */

	/**
	  * Open [this] Stream
	  */
	private function open(data : Object):Void {
		var mdata = ChannelMessage.StreamOpen(data);

		owner.send(name, mdata, write);
	}

	/**
	  * Close [this] Stream
	  */
	private function close():Void {
		closed = true;
		dispatch('closed', null);
	}

	/**
	  * Supply some data to [this] Stream
	  */
	private function write(chunk : StreamMessage<T>):Void {
		if (closed)
			return ;
		if (desired > 0) {
			trace('fulfilling queued READ requests');
			desired--;
			received.call( chunk );
		}
		else {
			trace('buffering data');
			buf.push(decode(chunk));
		}
	}

	/**
	  * Read a single chunk of data
	  */
	public function next(cb : T -> Void):Void {
		if (closed)
			return ;
		if (buf.length > 0) {
			trace('reading data from buffer');
			js.Browser.window.setTimeout(function() {
				cb(buf.pop());
			}, 1);
		}
		else {
			desired++;
			var called:Bool = false;
			received.once(function(sm) {
				if (!called)
					cb(decode(sm));
				else
					trace('ONCE fires multiple times');
				called = true;
			});
		}
	}

	/**
	  * Read a specified number of chunks
	  */
	public function read(count:Int, cb:Array<T>->Void):Void {
		var results:Array<T> = new Array();

		function wait() {
			next(function(chunk) {
				trace( chunk );
				results.push( chunk );

				if (results.length == count)
					cb( results );
				else
					wait();
			});
		}
		
		wait();
	}

	/**
	  * Get ALL input, as it arrives
	  */
	public function all(cb : T -> Void):Void {
		function step(v : T):Void {
			cb( v );
			next( step );
		}
		next( step );
	}

	/**
	  * Decode an incoming message
	  */
	private function decode(data : StreamMessage<T>):Null<T> {
		switch (data) {
			case SData( v ):
				return v;

			case SClose:
				close();
				return null;

			default:
				trace('Unexpected $data');
				return null;
		}
	}

/* === Instance Fields === */

	private var owner : Socket;
	private var name : String;
	private var buf : Array<T>;
	private var received : Signal<StreamMessage<T>>;
	private var desired : Int;
	private var closed : Bool;

	//private static 
}
