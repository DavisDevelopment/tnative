package tannus.msg;

import tannus.ds.Memory in Mem;
import tannus.ds.Maybe;
import tannus.io.Signal;

import tannus.msg.MessageType;

import Std.*;

using Lambda;
using tannus.ds.ArrayTools;
using StringTools;
using tannus.ds.StringUtils;

class Channel implements Pipeline {
	/* Constructor Function */
	public function new(p:Pipeline, n:String):Void {
		channels = new Map();
		name = n;
		parent = p;
		root = null;
		var pp:Pipeline = p;
		if (Std.is(pp, Socket)) {
			root = cast pp;
		}
		else {
			do {
				pp = cast(pp, Channel).parent;
			}
			while (!Std.is(pp, Socket));
			root = cast pp;
		}

		address = root.address.clone();
		address.addChannel( n );

		router = new PipelineRouter( this );
	}

/* === Instance Methods === */

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
	public function channel(name : String):Channel return (hasChannel( name ) ? openChannel( name ) : createChannel( name ));

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

	public function close():Void {
		parent.closeChannel( name );
	}
	public function sendMessage(m : Message<Dynamic>):Void {
		root.sendMessage( m );
	}
	public function send(action:String, data:Dynamic, ?onresponse:Dynamic->Void):Void {
		router.send(action, data, onresponse);
	}
	public function on<T>(action:String, handler:Message<T>->Void):Void {
		router.on(action, handler);
	}

	public function getPeerAddress():Maybe<Address> {
		var peer:Address = root.getPeerAddress();
		peer.channels = channelPath();
		return peer;
	}
	public function getAddress():Address {
		if (address == null) {
			address = root.getAddress();
			address.channels = channelPath();
		}
		return address;
	}
	public function getContext():SocketContext<Socket> return root.getContext();
	public function getPipe():Pipe<Message<Dynamic>> return root.getPipe();

	/**
	  * get the Channel portion of the 'path' to [this] Channel
	  */
	private function channelPath():Array<String> {
		var path = new Array();
		var p = parent;
		while (p != null) {
			if (is(p, Channel)) {
				var pc:Channel = cast p;
				path.push( pc.name );
				p = pc.parent;
			}
			else {
				p = null;
			}
		}
		path.reverse();
		return path;
	}

/* === Instance Fields === */

	public var name : String;
	public var parent : Pipeline;
	public var root : Null<Socket>;
	public var address : Address;
	public var router : PipelineRouter;
	
	private var channels : Map<String, Channel>;
}
