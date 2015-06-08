package tannus.io;

import tannus.ds.TwoTuple;

/**
  * What will be the core of the event-system in the new Tannus
  */
class Signal<T> {
	/* Constructor */
	public function new():Void {
		handlers = new Array();
	}

/* === Instance Fields === */

	//- An Array of Handlers
	private var handlers:Array<Handler<T>>;

/* === Instance Methods === */

	/**
	  * Checks if a Function is already attached to [this] Signal
	  */
	public function hasHandler(f : T->Void):Bool {
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
	private function getHandler(f : T->Void):Null<Handler<T>> {
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
	public function listen(f:T->Void, ?once:Bool=false):Void {
		var h:Handler<T> = new Handler(f, once);
		
		if (!hasHandler(f)) {
			handlers.push(h);
		}
	}

	/**
	  * Detach a listener from [this] Signal
	  */
	public function ignore(f:T->Void, ?_once:Bool=false):Void {
		var h:Null<Handler<T>> = getHandler( f );
		if (h != null) {
			handlers.remove( h );
			if (_once) {
				once(function(_v : T):Void {
					handlers.push( h );
				});
			}
		}
	}

	/**
	  * Alias to [listen]
	  */
	public inline function on(f:T->Void, ?once:Bool=false):Void {
		listen(f, once);
	}

	/**
	  * Alias to [ignore]
	  */
	public inline function off(f:T->Void, ?once:Bool=false):Void {
		ignore(f, once);
	}

	/**
	  * Attach a listener function which will only be invoked the very next broadcast
	  */
	public function once(f : T->Void):Void {
		listen(f, true);
	}

	/**
	  * Broadcast on [this] Signal
	  */
	public function broadcast(data : T):Void {
		for (h in handlers) {
			h.call( data );
		}
	}

	/**
	  * Alias to [broadcast]
	  */
	public function call(data : T):Void {
		broadcast(data);
	}
}

/**
  * A class to represent an Event Listener
  */
class Handler<T> {
	/* Constructor Function */
	public function new(func:T->Void, onc:Bool=false):Void {
		f = func;
		once = onc;
		_called = false;
	}

/* === Instance Fields === */

	//- The fuction to be invoked with this handler
	public var f:T->Void;

	//- Whether [this] Handler can only be invoked one time
	public var once:Bool;

	//- Whether [this] Handler has already been called
	public var _called:Bool;

/* === Instance Methods === */

	/**
	  * Checks whether [this] Handler's function is the same function as [func]
	  */
	public function equals(other : T->Void):Bool {
		return (Reflect.compareMethods(f, other));
	}

	/**
	  * Invokes [this] Handler with a given argument
	  */
	public function call(parameter : T):Void {
		if (!once || (once && !_called)) {
			f(parameter);
			_called = true;
		}
	}
}
