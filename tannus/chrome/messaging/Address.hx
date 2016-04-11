package tannus.chrome.messaging;

import tannus.http.Url;
import tannus.messaging.Message in SocketMessage;
import tannus.ds.Comparable;

import tannus.chrome.Runtime;
import tannus.chrome.Runtime.Message in ChromeMessage;
import tannus.chrome.Runtime.MessageSender;

@:forward
abstract Address (CAddress) from CAddress to CAddress {
	/* Constructor Function */
	public inline function new(data : TAddress):Void {
		this = new CAddress( data );
	}

/* === Instance Methods === */

	/**
	  * Check for equality between two Addresses
	  */
	@:op(A == B)
	public inline function equals(other : Address):Bool {
		return this.equals( other );
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
		return new Address({
			'app': msg.sender.id,
			'tab': msg.sender.tab
		});
	}
}

class CAddress implements Comparable<CAddress> {
	/* Constructor Function */
	public function new(d : TAddress):Void {
		data = d;
	}

/* === Instance Methods === */

	/**
	  * Compare [this] to [other]
	  */
	public function equals(other : CAddress):Bool {
		if (app == other.app) {
			return ((bg && other.bg) || (tab != null && other.tab != null && tab.id == other.tab.id));
		}
		else {
			return false;
		}
	}

	/**
	  * create and return a copy of [this]
	  */
	public function clone():Address {
		return new Address({
			'app': app,
		       	'id': id,
		        'tab': tab
		});
	}

	/**
	  * Pull additional information from a Message
	  */
	public inline function getMessageInfo(msg : SocketMessage):Void {
		data.id = msg.sender_id;
	}

	/**
	  * Convert [this] into a human-readable String
	  */
	public function toString():String {
		var s:String = '';
		if (app != null)
			s += '#($app)';
		if (tab != null)
			s += ':${tab.id}';
		if (id != null)
			s += '@$id';
		return s;
	}

/* === Computed Instance Fields === */

	public var app(get, never):Null<String>;
	private inline function get_app():Null<String> return data.app;

	public var id(get, never):Null<String>;
	private inline function get_id():Null<String> return data.id;

	public var tab(get, never):Null<Tab>;
	private inline function get_tab():Null<Tab> return data.tab;

	public var bg(get, never):Bool;
	private inline function get_bg():Bool return (data.bg != null ? data.bg : (tab == null));

/* === Instance Fields === */

	/* the underlying data Object */
	private var data : TAddress;
}

typedef TAddress = {
	?bg : Bool,
	?tab : Tab,
	?app : String,
	?id : String
};
