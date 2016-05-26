package tannus.concurrent.js;

import tannus.io.Blob;
import tannus.io.ByteArray;
import tannus.io.Signal;
import tannus.ds.Object;
import tannus.sys.Path;
import haxe.Serializer;
import haxe.Unserializer;
import tannus.concurrent.IBoss;


import js.html.Worker;
import js.Browser.document in doc;

class Boss implements IBoss {
	/* Constructor Function */
	public function new(script : Blob):Void {
		#if !macro
		worker = new Worker(script.toObjectURL());
		#end
		_message = new Signal();
		__bind();
	}

/* === Instance Methods === */

	/**
	  * Send a Message to [this] Worker
	  */
	public function send(data : Object):Void {
		Serializer.USE_CACHE = true;
		Serializer.USE_ENUM_INDEX = true;
		var enc:String = Serializer.run( data );
		worker.postMessage( enc );
	}

	/**
	  * Listen for Messages on [this] Worker
	  */
	public inline function onMessage(cb : Object->Void):Void {
		_message.on( cb );
	}

	/**
	  * Bind events and shit to the worker
	  */
	private function __bind():Void {
		worker.addEventListener('message', function(event) {
			var data:Object = cast Unserializer.run(Std.string(event.data));
			_message.call( data );
		});
	}

/* === Instance Fields === */

	private var _message:Signal<Object>;
	private var worker:Worker;
}
