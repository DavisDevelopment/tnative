package tannus.concurrent;

import tannus.io.ByteArray;
import tannus.io.Signal;
import tannus.io.Ptr;
import tannus.ds.Maybe;

import haxe.Serializer;
import haxe.Unserializer;

#if !macro
import js.html.Worker;
import js.html.WorkerContext;
#end

/**
  * Base Class for JavaScript-Based Worker-Bosses
  */
class JSBoss<I, O> {
	/* Constructor Function */
	public function new(name : String):Void {
		var entry:Dynamic = null; 
	}

/* === Instance Fields === */

	public var url : String;
}
