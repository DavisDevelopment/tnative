package tannus.net;

import tannus.io.Byte;
import tannus.io.ByteArray;
import tannus.io.Ptr;
import tannus.io.Signal;

import tannus.net.Host;

/**
  * BaseClass for Network Access
  */
class Socket {
	/* Constructor Function */
	public function new():Void {
		sock = new Sock();
	}

/* === Instance Methods === */

	/**
	  * Connect to a given Host on the given Port
	  */
	public function connect(host:Host, port:Int):Void {
		sock.connect(host, port);
	}

/* === Instance Fields === */
	public var sock:Sock;
}

#if !js
typedef Sock = sys.net.Socket;
#end
