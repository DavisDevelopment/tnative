package tannus.msg;

import tannus.msg.MessageType;

@:allow( tannus.msg.Address )
class SocketContext <T:Socket> {
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

		bus.receive.on( messageReceived );
	}

	/**
	  * handle an incoming Message
	  */
	public function packetReceived(packet : Dynamic):Void {
		var message:Message<Dynamic> = modem.decode( packet );
		messageReceived( message );
	}

	public function messageReceived(message : Message<Dynamic>):Void {

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
		return pipe;
	}

/* === Instance Fields === */

	private var modem : BaseModem;
	private var pipe : Pipe<Dynamic>;
	private var bus : Pipe<Message<Dynamic>>;
	private var sockets : Map<String, T>;
}
