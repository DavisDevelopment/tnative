package tannus.io;

import tannus.ds.TwoTuple;

/**
  * What will be the core of the event-system in the new Tannus
  */
class Signal2<A, B> {
	/* Constructor */
	public function new():Void {
		handlers = new Array();
		ondelete = null;
	}

/* === Instance Fields === */

	//- An Array of Handlers
	private var handlers:Array<Handler<A, B>>;

	//- Function to call when [delete] is called
	public var ondelete:Null<Void->Void>;

/* === Instance Methods === */

	/**
	  * Checks if a Function is already attached to [this] Signal
	  */
	public function hasHandler(f : A->B->Void):Bool {
		for (h in handlers) {
			if (h.equals(f)) {
				return true;
			}
		}
		return false;
	}

	/**
	  * Finds the 'Handler' instance for [f]
	  */
	private function getHandler(f : A->B->Void):Null<Handler<A, B>> {
		for (h in handlers) {
			if (h.equals(f)) {
				return h;
			}
		}
		return null;
	}

	/**
	  * Attach a listener function to [this] Signal
	  */
	public function listen(f:A->B->Void, ?once:Bool=false):Void {
		var h:Handler<A, B> = new Handler(f, once);
		
		if (!hasHandler(f)) {
			handlers.push(h);
		}
	}

	/**
	  * Detach a listener from [this] Signal
	  */
	public function ignore(f:A->B->Void, ?_once:Bool=false):Void {
		var h:Null<Handler<A, B>> = getHandler( f );
		if (h != null) {
			handlers.remove( h );
			if (_once) {
				once(function(_a, _b):Void {
					handlers.push( h );
				});
			}
		}
	}

	/**
	  * Alias to [listen]
	  */
	public inline function on(f:A->B->Void, ?once:Bool=false):Void {
		listen(f, once);
	}

	/**
	  * Alias to [ignore]
	  */
	public inline function off(f:A->B->Void, ?once:Bool=false):Void {
		ignore(f, once);
	}

	/**
	  * Attach a listener function which will only be invoked the very next broadcast
	  */
	public function once(f : A->B->Void):Void {
		listen(f, true);
	}

	/**
	  * Broadcast on [this] Signal
	  */
	public function broadcast(a:A, b:B):Void {
		for (h in handlers) {
			h.call(a, b);
		}
	}

	/**
	  * Alias to [broadcast]
	  */
	public function call(a:A, b:B):Void {
		broadcast(a, b);
	}

	/**
	  * 'destroy' [this] Signal
	  */
	public function delete():Void {
		if (ondelete != null)
			ondelete();
	}
}

/**
  * A class to represent an Event Listener
  */
private class Handler<A, B> {
	/* Constructor Function */
	public function new(func:A->B->Void, onc:Bool=false):Void {
		f = func;
		once = onc;
		_called = false;
	}

/* === Instance Fields === */

	//- The fuction to be invoked with this handler
	public var f:A->B->Void;

	//- Whether [this] Handler can only be invoked one time
	public var once:Bool;

	//- Whether [this] Handler has already been called
	public var _called:Bool;

/* === Instance Methods === */

	/**
	  * Checks whether [this] Handler's function is the same function as [func]
	  */
	public function equals(other : A->B->Void):Bool {
		return (Reflect.compareMethods(f, other));
	}

	/**
	  * Invokes [this] Handler with a given argument
	  */
	public function call(one:A, two:B):Void {
		if (!once || (once && !_called)) {
			f(one, two);
			_called = true;
		}
	}
}
