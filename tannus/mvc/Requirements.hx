package tannus.mvc;

import tannus.io.VoidSignal;

import tannus.ds.Async;
import tannus.ds.AsyncStack;

using Lambda;
using tannus.ds.MapTools;

class Requirements {
	/* Constructor Function */
	public function new():Void {
		tasks = new Map();

		complete = new VoidSignal();
	}

/* === Instance Methods === */

	/**
	  * Add a requirement
	  */
	public inline function add(name:String, task:Async):Void {
		//tasks.under( task );
		tasks.set(name, task);
	}

	/**
	  * Wait for the 'complete' event
	  */
	public inline function onComplete(f : Void->Void):Void {
		complete.on( f );
	}

	/**
	  * Perform the provided Tasks to meet [this] Requirements
	  */
	public function meet(?cb : Void -> Void):Void {
		if (cb != null)
			onComplete( cb );

		var stack:AsyncStack = new AsyncStack();
		for (name in tasks.keys()) {
			stack.under(tasks[name]);
		}

		stack.run( complete.fire );
	}

/* === Instance Fields === */

	private var tasks : Map<String, Async>;
	public var complete : VoidSignal;

}
