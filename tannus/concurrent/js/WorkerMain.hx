package tannus.concurrent.js;

import tannus.io.Blob;
import tannus.io.ByteArray;
import tannus.io.Signal;
import tannus.ds.Object;
import tannus.concurrent.js.Worker;
import tannus.internal.CompileTime in Ct;

import haxe.Serializer;
import haxe.Unserializer;

class WorkerMain {
	/* Constructor Function */
	public function new():Void {
		trace( '::mainClass::' );
		var werk:Worker = Type.createInstance(Ct.execute('::mainClass::'), [this]);
		worker = werk;

		var _ondata = onData;
		untyped {
			__js__('onmessage = _ondata');
		};
	}

/* === Instance Methods === */

	/**
	  * Send some data
	  */
	public function send(data : Object):Void {
		(untyped __js__('postMessage'))(Serializer.run( data ));
	}

	/**
	  * Handle incoming data
	  */
	@:access(tannus.concurrent.js.Worker)
	private function onData(event : Dynamic):Void {
		var encoded:String = Std.string(event.data);
		var decoded:Object = new Object(Unserializer.run(encoded));
		worker._msg.call( decoded );
	}

/* === Instance Fields === */

	private var worker : Worker;

/* === Static Stuff === */

	/* Main Entry Point */
	public static function main():Void {
		var me = new WorkerMain();
	}
}
