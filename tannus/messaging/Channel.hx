package tannus.messaging;

import tannus.messaging.Messager in Socket;
import tannus.messaging.Message;
import tannus.messaging.StreamMessage;
import tannus.messaging.MessageOutStream in OStream;
import tannus.messaging.MessageInStream in IStream;
import tannus.messaging.ChannelMessage;

import tannus.ds.Object;
import tannus.io.Signal;

class Channel {
	/* Constructor Function */
	public function new(s:Socket, nam:String):Void {
		name = nam;
		owner = s;
		received = new Signal();
		streams = new Map();

		owner.on(name, _received);
	}

/* === Instance Methods === */

	/**
	  * Send some data over [this] Channel
	  */
	public function send(data:Object, ?cb:Object->Void):Void {
		owner.send(name, Normal(data), cb);
	}

	/**
	  * Listen for incoming data on [this] Channel
	  */
	public function listen(f : Message->Void):Void {
		received.on( f );
	}

	/**
	  * Open up a sub-channel of [this] one
	  */
	public function openChannel(sub : String):Channel {
		var chan:Channel = new Channel(owner, '$name:$sub');
		return chan;
	}

	/**
	  * Define a named Stream
	  */
	@:access(tannus.messaging.MessageOutStream)
	public function stream<T>(sname : String):OStream<T> {
		var ostream = new OStream(owner, sname);
		
		owner.on('$name>>$sname', function(msg) {
			switch (cast(msg.data, ChannelMessage)) {
				case StreamOpen( data ):
					ostream.open(data, function(value:StreamMessage<T>) {
						msg.reply(value);
					});

				default:
					throw 'Thats a bad.. mkay';
			}
		});
		
		return ostream;
	}

	/**
	  * Open a Stream
	  */
	@:access(tannus.messaging.MessageInStream)
	public function openStream<T>(sname:String, data:Object):IStream<T> {
		var istream:IStream<T> = new IStream(owner, '$name>>$sname');

		istream.open( data );

		return istream;
	}

	/**
	  * Handle incoming message
	  */
	private function _received(msg : Message):Void {
		if (msg.data.istype(ChannelMessage)) {
			var cmsg:ChannelMessage = cast msg.data;
			switch (cmsg) {
				case Normal(data):
					msg.data = data;
					received.call( msg );

				default:
					trace( msg );
					throw 'Unexpected $cmsg';
			}
		}
	}

/* === Instance Fields === */

	private var received : Signal<Message>;
	private var streams : Map<String, OStream<Dynamic>>;
	
	private var owner : Socket;
	private var name : String;
}
