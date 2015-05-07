package tannus.concurrent.js;

import tannus.io.ByteArray;
import tannus.io.Signal;
import tannus.io.Ptr;
import tannus.ds.Maybe;
import tannus.concurrent.IBoss;

import haxe.Serializer;
import haxe.Unserializer;

#if !macro
import js.html.Worker;
import js.html.WorkerContext;
#end

/**
  * Base Class for JavaScript-Based Worker-Bosses
  */
class JSBoss<I, O> implements IBoss<I, O> {
	/* Constructor Function */
	public function new(ur : String):Void {
		url = ur;
		message = new Signal();

		#if js
			_worker = new Worker(url);
		#end
		__init();
	}

/* === Instance Methods === */

	/**
	  * Initialize [this] Boss
	  */
	private function __init():Void {
		_worker.onmessage = function(e) {

			message.call(cast e.data);
		};
	}

	/**
	  * Send some Data
	  */
	public function send(data:I, cb:O->Void):Void {
		message.once(function(response : O) {
			cb( response );
		});

		_worker.postMessage( data );
	}

/* === Instance Fields === */

	public var url : String;
	public var message : Signal<O>;

#if (js && !node)
	private var _worker : Worker;
#else
	private var _worker : Dynamic;
#end
}
