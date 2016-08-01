package tannus.msg;

import Type.*;

using Lambda;
using tannus.ds.ArrayTools;
using StringTools;
using tannus.ds.StringUtils;

class Address {
	/* Constructor Function */
	public function new():Void {
		socketId = '';
		channels = new Array();
		action = '';
	}

/* === Instance Methods === */

	public function toString():String {
		return (socketId + '.' + channels.join( '.' ) + '/' + action);
	}

	public function resolve<T:Pipeline>(context:SocketContext<Dynamic>, callback:Null<T>->Void):Void {
		if (context.sockets.exists( socketId )) {
			var socket:Null<Pipeline> = context.sockets.get( socketId );
			if (channels.length > 0) {
				var l = channels.copy();
				do {
					socket = socket.channel(l.shift());
				}
				while (!l.empty());
			}
			callback( socket );
		}
		else {
			callback( null );
		}
	}

	public function clone():Address {
		var c = createEmptyInstance(getClass( this ));
		c.socketId = socketId;
		c.action = action;
		c.channels = channels.copy();
		return c;
	}

	public function relative(channelPath : String):Address {
		var parts = channelPath.split( '/' );
		var rel = clone();
		var cl = rel.channels;
		for (x in parts) {
			if (x.empty() || x == '.') {
				continue;
			}
			else if (x == '..') {
				cl.pop();
			}
			else {
				cl.push( x );
			}
		}
		return rel;
	}

	public function addChannel(name : String):Void {
		channels = channels.concat(name.split('.'));
	}

/* === Instance Fields === */

	public var socketId : String;
	public var channels : Array<String>;
	public var action : String;

/* === Static Methods === */

	public static function fromString(s : String):Address {
		var sid : String;
		var domain : Array<String>; 
		if (s.startsWith( '/' )) {
			s = s.after('/');
			sid = '';
		}
		else {
			domain = s.before( '/' ).split( '.' );
			sid = domain.shift();
		}
		var action = s.after( '/' );
		var result = new Address();
		result.socketId = sid;
		result.channels = domain;
		result.action = action;
		return result;
	}
}
