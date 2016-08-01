package tannus.msg;

import haxe.Json;
import haxe.Serializer;
import haxe.Unserializer;

import tannus.msg.MessageEncoding in Enc;

class BaseModem implements Modem<Dynamic, Message<Dynamic>> {
	public function new():Void {

	}

/* === Instance Methods === */

	public function encode(rawMessage : Message<Dynamic>):Dynamic {
		return encodeMessage(rawMessage, {
			encoding: rawMessage.encoding,
			message: encodeMessage( rawMessage )
		});
	}
	private function encodeMessage(m:Message<Dynamic>, ?data:Dynamic):Dynamic {
		var encoding:MessageEncoding = cast m.encoding;
		var value:Dynamic = m.data;
		if (data != null) {
			value = data;
		}
		switch ( encoding ) {
			case Enc.StructuredClone:
				return value;
			case Enc.HaxeSerialization:
				return Serializer.run( value );
			case Enc.Json:
				return Json.stringify( value );
		}
	}

	public function decode(message : Dynamic):Message<Dynamic> {
		var raw:{encoding:MessageEncoding,message:Dynamic} = message;
		if (Std.is(message, String)) {
			var str:String = cast message;
			try {
				raw = cast Json.parse( str );
			}
			catch (err : Dynamic) {
				trace( err );
				raw = cast Unserializer.run( str );
			}
		}
		return decodeMessage(raw.message, raw.encoding);
	}
	private function decodeMessage(message:Dynamic, encoding:MessageEncoding):Message<Dynamic> {
		switch ( encoding ) {
			case Enc.StructuredClone:
				return message;
			case Enc.Json:
				return cast Json.parse(cast message);
			case Enc.HaxeSerialization:
				return cast Unserializer.run(cast message);
		}
	}

}
