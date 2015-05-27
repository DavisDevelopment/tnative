package tannus.ds;

import tannus.io.Signal;

class AsyncStack {
	/* Constructor Function */
	public function new():Void {
		funcs = new Array();

		complete = new Signal();
	}

/* === Instance Methods === */

	/**
	  * Add a Callback to the Stack
	  */
	public inline function push(f : Callback):Void {
		funcs.push( f );
	}

	/**
	  * Calls the Func at index [i], if it exists
	  */
	private inline function call(i:Int, cb:Func):Void {
		var f = funcs[i];
		if (f != null)
			funcs[i]( cb );
		else
			complete.call( null );
	}

	/**
	  * Run the full Stack
	  */
	public function run(?done:Func):Void {
		var i:Int = 0;

		if (done != null) {
			complete.on(function(x) done());
		}
		
		function next():Void {
			i++;
			call(i, next);
		}

		call(i, next);
	}

/* === Instance Fields === */

	/* Array of Callbacks */
	private var funcs : Array<Callback>;

	/* Function to run when [this] Stack is complete */
	public var complete : Signal<Dynamic>;
}

private typedef Func = Void->Void;
private typedef Callback = Func->Void;
