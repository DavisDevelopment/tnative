package tannus.concurrent.js;

import tannus.io.Blob;
import tannus.io.ByteArray;
import tannus.io.Signal;
import tannus.ds.Object;
import haxe.Serializer;
import haxe.Unserializer;
import tannus.concurrent.IBoss;

#if !macro

	import js.html.Worker;

#end
	import haxe.macro.Context;
	import haxe.macro.Expr;
	using haxe.macro.ExprTools;
	
#if macro
	typedef Worker = Dynamic;
#end

class Boss implements IBoss {
	/* Constructor Function */
	public function new(scriptBlob : Blob):Void {
		#if !macro
		worker = new Worker(scriptBlob.toObjectURL());
		#end
		_message = new Signal();
		worker.onmessage = function(e) {
			var enc:String = Std.string(e.data);
			var data:Object = cast Unserializer.run( enc );
			_message.call( data );
		};
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

/* === Instance Fields === */

	private var _message:Signal<Object>;
	private var worker:Worker;

/* === Statis Methods === */

	/**
	  * Create a new Boss with macro-licious simplicity
	  */
	public static macro function create(build_file : String):ExprOf<tannus.concurrent.js.Boss> {
		var ebf = Context.makeExpr(build_file, Context.currentPos());
		return macro (new pman.Boss(tannus.concurrent.Workers.buildBlob($ebf)));
	}
}
