package tannus.chrome.net;

import tannus.io.Signal;
import tannus.ds.Object;

import js.html.ArrayBuffer;

class Sockets {
	/* Create a new Socket */
	public static function create_raw(properties:SocketProperties, cb:Int->Void):Void {
		lib.create(properties, function(obj : Object):Void {
			var id:Int = cast obj['socketId'];
			trace( id );
			cb( id );
		});
	}

	/* Create Socket */
	public static function create(props:SocketProperties, cb:Socket->Void):Void {
		create_raw(props, untyped cb);
	}

	/* Connect the specified Socket */
	public static function connect(id:Int, address:String, port:Int, callback:Int->Void):Void {
		lib.connect(id, address, port, callback);
	}

	/* Disconnect the specified socket */
	public static function disconnect(id:Int, cb:Void->Void):Void {
		lib.disconnect(id, cb);
	}

	/* Listen for data on the specified Socket */
	public static function onReceive(id:Int, cb:ArrayBuffer->Void):Void {
		lib.onReceive.addListener(function(event:Dynamic) {
			if (event.socketId == id) {
				cb(cast event.data);
			}
		});
	}

	/* The object used internally */
	private static var lib(get, never):Dynamic;
	private static inline function get_lib():Dynamic {
		return untyped __js__('chrome.sockets.tcp');
	}
}

typedef SocketProperties = {
	?persistent : Bool,
	?name : String,
	?bufferSize : Int
};
