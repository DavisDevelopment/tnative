package tannus.chrome.messaging;

import tannus.messaging.*;
import tannus.ds.Object;
import tannus.ds.Maybe;
import tannus.io.Ptr;
import tannus.io.Signal;
import tannus.chrome.Tabs;
import tannus.chrome.Tab;
import tannus.chrome.Runtime;

import tannus.chrome.messaging.ExtMessager;

using Lambda;
using tannus.ds.ArrayTools;

@:access(chrome.messaging.ExtMessager)
class BGServer extends MessagerPool {
	/* Constructor Function */
	public function new():Void {
		super();
	}

/* === Instance Methods === */

	/**
	  * Create a new Messager
	  */
	override public function createMessager():Messager {
		var messager = new ExtMessager(true);
		
		sockets.push(cast messager);
		messager.pool = this;

		return (cast messager);
	}

	/**
	  * Determine whether a Messager already exists which is connected to a given Tab
	  */
	public function getMessagerByTab(tabid : Int):Null<ExtMessager> {
		var mes = cast sockets.macfirstMatch(
			cast(_, ExtMessager).tab.value != null &&
			cast(_, ExtMessager).tab.value.id == tabid
		);
		return mes;
	}

	/**
	  * Get the Messager (if any) with the given Address
	  */
	public function getMessagerByAddress(a : Address):Null<ExtMessager> {
		var esockets:Array<ExtMessager> = cast sockets;
		return esockets.macfirstMatch(_.peerAddress != null && _.peerAddress.equals( a ));
	}
}
