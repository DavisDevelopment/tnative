package tannus.chrome.messaging;

import tannus.http.Url;
import tannus.messaging.Message;

import tannus.chrome.Runtime;
import tannus.chrome.Runtime.Message in ChromeMessage;
import tannus.chrome.Runtime.MessageSender;

@:forward
abstract Address (TAddress) to TAddress {
	/* Constructor Function */
	public inline function new(data : TAddress):Void {
		this = data;
	}

/* === Instance Methods === */

	/**
	  * Check for equality between two Addresses
	  */
	@:op(A == B)
	public static inline function equals(a:Address, b:Address):Bool {
		return (
			((a.id == null && b.id == null) || a.id == b.id) &&
			((a.tab == null && b.tab == null) || (a.tab.id == b.tab.id))
		);
	}

/* === Instance Fields === */

	/* whether [this] address is to a background-page */
	public var bg(get, never):Bool;
	private inline function get_bg():Bool {
		return (this.bg != null ? this.bg : false);
	}

/* === Casting Methods === */

	/**
	  * Build an address from a Chrome Message
	  */
	@:from
	public static function fromChromeMessage(msg : ChromeMessage):Address {
		var addr:TAddress = {};
		addr.id = msg.sender.id;
		addr.tab = msg.sender.tab;
		addr.bg = (addr.tab == null);
		return new Address( addr );
	}
}

typedef TAddress = {
	@:optional var bg : Bool;
	@:optional var tab : Tab;
	@:optional var id : String;
};
