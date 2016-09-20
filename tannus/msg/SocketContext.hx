package tannus.msg;

import tannus.msg.MessageType;

@:allow( tannus.msg.Address )
@:access( tannus.msg.Socket )
class SocketContext <T : Socket> {
	/* Constructor Function */
	public function new():Void {
		sockets = new Map();
		modem = new BaseModem();
	}

/* === Instance Methods === */

	/**
	  * create event bindings, and prepare to begin receiving Messages
	  */
	public function listen():Void {
		if (bus == null) {
			var err = 'DumbAssError: SocketContext must have a [bus] field to be used';
			#if js
			js.Browser.console.error( err );
			#else
			throw err;
			#end
		}

		pipe.receive.on( packetReceived );
	}

	/**
	  * handle an incoming Message
	  */
	public function packetReceived(packet : Dynamic):Void {
		var message:Message<Dynamic> = modem.decode( packet );

		if (message.type.equals( Connect )) {
			var addr:Address = message.address;
			var sock = createSocket( addr );
			attachSocket( sock );
			var metaChannel:Channel = sock.channel('::meta::');
			metaChannel.send('connected', true, function(res) {
				trace('response: $res');
			});
			return ;
		}

		messageReceived( message );
	}

	public function messageReceived(message : Message<Dynamic>):Void {
		if (message.type.equals( Connect )) {

		}
		resolve(message.address, function(p) {
			p.receive( message );
		});
	}

	/**
	  * resolve an Address to a Socket
	  */
	public function resolve(a:Address, cb:Null<Pipeline>->Void):Void {
		a.resolve(this, cb);
	}

	/**
	  * gets the underlying base Pipe
	  */
	public function getPipe():Pipe<Message<Dynamic>> {
		return bus;
	}

	public function sendMessage(m : Message<Dynamic>):Void {
		var raw = modem.encode( m );
		pipe.send( raw );
	}

	public function attachSocket(s : T):Void {
		s.context = cast this;
	}

	public function createSocket(address : Address):T {
		return new Socket();
	}

	public function connectSocket(s:Socket, done:Void->Void):Void {
		var connectMessage = new Message();
		connectMessage.type = Connect;
		var a = connectMessage.address;
		a.socketId = s.id;
		sendMessage( connectMessage );
		var meta = s.channel('::meta::');
		meta.on('connected', function(m : Message<Bool>) {
			var status:Bool = m.data;
			trace('connection status: $status');
			m.reply('dope');
			done();
		});
	}

/* === Instance Fields === */

	private var modem : BaseModem;
	private var pipe : Pipe<Dynamic>;
	private var bus : Pipe<Message<Dynamic>>;
	private var sockets : Map<String, T>;
}
