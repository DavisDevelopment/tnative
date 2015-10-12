package tannus.chrome.net;

import tannus.io.ByteArray;

using tannus.chrome.net.Sockets;

abstract Socket (Int) {
	public inline function new(id : Int):Void {
		this = id;
	}

/* === Instance Methods === */

	/**
	  * Connect to the given address
	  */
	public inline function connect(address:String, port:Int, callback:Int->Void):Void {
		this.connect(address, port, callback);
	}

	/**
	  * Disconnect
	  */
	public inline function disconnect(cb : Void->Void):Void this.disconnect( cb );

	/**
	  * Listen for data on [this] Socket
	  */
	public function listen(cb : ByteArray->Void):Void {
		this.onReceive(function(dat) {
			cb(ByteArray.fromArrayBuffer( dat ));
		});
	}
}
