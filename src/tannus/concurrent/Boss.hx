package tannus.concurrent;

import tannus.concurrent.IBoss;
import haxe.macro.Context;

using haxe.macro.ExprTools;
@:forward
abstract Boss<I, O> (IBoss<I, O>) from IBoss<I, O> to IBoss<I, O> {
	/* Constructor Function */
	public inline function new(b : IBoss<I, O>):Void {
		this = b;
	}

	/**
	  * The only global interface to obtain a Boss instance
	  */
	public static macro function hire( worker ) {
		var fl = Context.getDefines();
		/* JavaScript (Not NodeJS) Target */
		if (fl.exists('js')) {
			return macro new tannus.concurrent.Boss(tannus.concurrent.js.Workers.create($worker, '../dist/html/scripts/'));
		}

		else if (fl.exists('python')) {
			return macro new tannus.concurrent.Boss(new tannus.concurrent.python.PyBoss($worker));
		}

		/* Current Target Unsupported */
		else {
			return Context.error('WorkerError: Current Target Unsupported', Context.currentPos());
		}
	}
}
