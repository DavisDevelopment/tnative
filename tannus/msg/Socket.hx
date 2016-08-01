package tannus.msg;

import tannus.ds.Memory in Mem;
import tannus.ds.Maybe;
import tannus.io.Signal;

import tannus.msg.MessageType;

using Lambda;
using tannus.ds.ArrayTools;
using StringTools;
using tannus.ds.StringUtils;

class Socket implements Pipeline {
	/* Constructor Function */
	public function new():Void {
		id = Mem.allocRandomId( 10 );
		address = new Address();
		address.socketId = id;
		router = new PipelineRouter( this );
	}

/* === Instance Methods === */

	public function sendMessage(m : Message<Dynamic>):Void {
		context.getPipe().send( m );
	}
	public function send(action:String, data:Dynamic, ?onreply:Dynamic->Void):Void {
		router.send(action, data, onreply);
	}
	public function on<T>(action:String, handler:Message<T>->Void):Void {
		router.on(action, handler);
	}
	public function close():Void {
		var closeMessage = createMessage();
		closeMessage.type = MessageType.Close;
		sendMessage( closeMessage );
	}
	public function createMessage():Message<Dynamic> {
		var source:Address = address.clone();
		var maddress:Maybe<Address> = getPeerAddress();
		if ( !maddress.exists ) {
			var err = 'Error: Pipeline not yet connected to peer';
			trace( err );
			throw err;
		}

		var msg:Message<Dynamic> = new Message();
		msg.source = source;
		msg.address = maddress;
		return msg;
	}

	/**
	  * routes an incoming Message to either its corresponding handler function, or one of the Channels attached to [this] Socket
	  */
	public function receive(m : Message<Dynamic>):Void {
		router.receive( m );
	}

	public function createChannel(name : String):Channel {
		if (hasChannel( name )) {
			throw 'Error: A Channel by that name already exists on current Pipeline';
		}
		var chan = new Channel(this, name);
		channels[name] = chan;
		return chan;
	}
	public function openChannel(name : String):Channel {
		if (hasChannel( name )) {
			return channels[name];
		}
		else {
			throw 'Error: Cannot open non-existent Channel';
		}
	}
	public function closeChannel(name : String):Void {
		var chan = channels.get( name );
		if (chan != null) {
			// pinch a cheek
		}
		channels.remove( name );
	}
	public function hasChannel(name : String):Bool return channels.exists( name );

	public function getPeerAddress():Maybe<Address> {
		return peer;
	}
	public function getAddress():Address return address;
	public function getContext():SocketContext<Socket> return context;
	public function getPipe():Pipe<Message<Dynamic>> return context.getPipe();

/* === Instance Fields === */

	public var id : String;
	public var address : Address;
	public var router : PipelineRouter;
	
	private var context : SocketContext<Socket>;
	private var channels : Map<String, Channel>;
	private var peer : Null<Address> = null;
}
