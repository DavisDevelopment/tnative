package tannus.msg;

import tannus.ds.Memory in Mem;
import tannus.internal.TypeTools;

class Message<T> {
	/* Constructor Function */
	public function new():Void {
		id = Mem.allocRandomId( 6 );
		type = MessageType.Normal;
		encoding = MessageEncoding.StructuredClone;
		onReply = null;
	}

/* === Instance Methods === */

	/**
	  * send a reply to [this] Message
	  */
	public dynamic function reply(responseData : Dynamic):Message<Dynamic> {
		var rm = clone();
		rm.type = Reply;
		rm.data = cast responseData;
		return untyped rm;
	}

	public function clone():Message<T> {
		return TypeTools.deepCopy( this );
	}

/* === Instance Fields === */

	public var id(default, null):String;
	public var type : MessageType;
	public var data : T;
	public var encoding : MessageEncoding;
	public var source : Address;
	public var address : Address;

	@:allow( tannus.msg.Pipeline )
	@:allow( tannus.msg.PipelineRouter )
	private var onReply : Null<T -> Void>;
}
