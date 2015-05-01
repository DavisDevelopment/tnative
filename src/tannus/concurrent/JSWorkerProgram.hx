package tannus.concurrent;

import tannus.io.ByteArray;
import tannus.io.Signal;
import tannus.io.Ptr;

import tannus.concurrent.JSWorker;

/**
  * Prototype implementation of a flexible, reusable interface to HTML5's WebWorker API
  */
@:build(tannus.concurrent.WorkerBuildTools.linkToGutClass())
class JSWorkerProgram {
	/* Constructor Function */
	public function new(cl : Class<JSWorker<Dynamic, Dynamic>>):Void {

		var slave:JSWorker<Dynamic, Dynamic> = cast Type.createInstance(cl, []);

		onMessage(function(_data : String) {
			var data:Dynamic = Us.run( _data );
		
			slave.process(data, function(response:Dynamic):Void {
				var _res:String = S.run( response );

				sendMessage( _res );
			});
		});
	}

/* === Instance Methods === */



/* === Instance Fields === */



/* === Static Fields === */

	/**
	  * Set the global 'onmessage' variable
	  */
	private static inline function onMessage(handler : Dynamic->Void):Void {
		var _h:Dynamic->Void = (function(e : Dynamic):Void {
			handler( e.data );
		});

		untyped __js__('onmessage = _h');
	}

	/**
	  * Invoke the 'postMessage' function
	  */
	private static inline function sendMessage(data : ByteArray):Void {
		var _d:String = (data.toString());

		untyped __js__('postMessage( _d )');
	}

	/**
	  * Entry Point, as this will count as it's own program
	  */
	public static function main():Void {
		var me = new JSWorkerProgram( GutClass );
	}
}

private typedef S = haxe.Serializer;
private typedef Us = haxe.Unserializer;
