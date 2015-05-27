package tannus.concurrent.python;

import tannus.concurrent.python.Multip.Connection;

class Pipes {
	/* Array of all 'sender' Connections */
	public static var conns:Array<Entry>;
	public static function __init__() {
		conns = new Array();
	}

	/**
	  * Add a Connection
	  */
	public static function add(c:Connection, f:Dynamic->Void):Void {
		conns.push({con:c, fn:f});
	}

	/**
	  * 'poll' all Connections, and return those that have data
	  */
	public static function poll():Array<Entry> {
		return conns.filter(function(e) {
			return (e.con.poll());
		});
	}
}

private typedef Entry = {
	var con : Connection;
	var fn  : Dynamic->Void;
};
