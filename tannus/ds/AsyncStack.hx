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

	/**
	  * [for backwards compatibility]
	  * Add a Callback to the Stack
	  */
	public inline function push(f : Async):Void {
		under( f );
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
	
	private var completion : VoidSignal;
}

private typedef Func = Void->Void;
private typedef Callback = Func->Void;
