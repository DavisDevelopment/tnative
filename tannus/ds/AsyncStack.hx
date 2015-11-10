package tannus.ds;

import tannus.io.Signal;
import tannus.io.VoidSignal;
import haxe.macro.Expr;
import tannus.ds.Async.Async;

using haxe.macro.ExprTools;

class AsyncStack extends Stack<Async> {
	/* Constructor Function */
	public function new():Void {
		super();
		completion = new VoidSignal();
	}
	
/* === Instance Methods === */

	/**
	  * handle the next Async, and plan to do so again
	  */
	private function callNext():Void {
		if ( !empty ) {
			var action:Async = pop();
			action( callNext );
		}
		else {
			completion.call();
		}
	}
	
	/**
	  * run the entire AsyncStack, and listen for it's completion
	  */
	public function run(done : Void->Void):Void {
		if (empty) {
			done();
		}
		else {
			completion.once( done );
			callNext();
		}
	}
	
	private var completion : VoidSignal;
}

class OldAsyncStack {
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
	  * Append some shit to the Stack
	  */
	public macro function append(self:Expr, action:Expr):Expr {
		function emapper(e : Expr) {
			switch (e.expr) {
				case ExprDef.EContinue:
					return macro (next());

				default:
					return e.map(emapper);
			}
		}
		action = action.map(emapper);
		return macro {
			$self.push(function(next) {
				$action;
			});
		};
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
