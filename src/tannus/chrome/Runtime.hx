package tannus.chrome;

import tannus.ds.Object;
import tannus.ds.Maybe;
import tannus.ds.ActionStack;
import tannus.io.Ptr;
import tannus.io.Signal;
import tannus.io.ByteArray;

import haxe.Serializer;
import haxe.Unserializer;

class Runtime {

	/**
	  * Sends a message to another application/extension
	  */
	public static function sendMessage(tid:String, data:Object, ?onresponse:Maybe<Object->Void>):Void {
		lib.sendMessage(tid, data, {}, function(response:Object) {
			if (onresponse) {
				var f:Object->Void = onresponse;
				f( response );
			}
		});
	}

	/**
	  * Listen for incoming message, without the convenience-wrapper
	  */
	public static function onMessageRaw(callb : Dynamic->MessageSender->Void):Void {
		lib.onMessage.addListener( callb );
	}

	/**
	  * Listen for incoming messages
	  */
	public static function onMessage(callb : Message->Void):Void {
		lib.onMessage.addListener(function(d:Dynamic, sendr:Dynamic, sendResponse:Dynamic->Void) {
			callb({
				'data'   : d,
				'sender' : (cast sendr),
				'respond': sendResponse
			});
		});
	}
	
	/**
	  * The ID of the current application/extension
	  */
	public static var id(get, never):String;
	private static inline function get_id() return (lib.id + '');
	/**
	  * Reference to the object being used internally
	  */
	public static var lib(get, never):Dynamic;
	private static inline function get_lib():Dynamic return untyped __js__('chrome.runtime');
}

private typedef Message = {
	var data : Object;
	var sender : MessageSender;
	var respond : Object -> Void;
};

private typedef MessageSender = {
	@:optional
	var tab : Maybe<Tab>;
	@:optional
	var id : Maybe<String>;
	@:optional
	var url : Maybe<String>;
};
