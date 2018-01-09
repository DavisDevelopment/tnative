package tannus.io;

//import tannus.io.Ptr;

class Signal<T> {
	/* Constructor Function */
	public function new():Void {
		handlers = new Array();
		ondelete = (function() null);
	}

/* === Instance Methods === */

	/** * Adds a new Handler to the list of Handlers */
	private inline function add(handler : Handler<T>):Void {
		handlers.push( handler );
	}

	/**
	  * Listen for data on [this] Signal
	  */
	public function listen(f:T->Void, once:Bool=false):Void {
		if (!once) {
			add(Normal( f ));
		} 
		else {
			add(Once( f ));
		}
	}

	/**
	  * Alias to 'listen'
	  */
	public inline function on(f:T->Void, once:Bool=false):Void {
		listen(f, once);
	}

	/**
	  * Listen for data on [this] Signal, only once
	  */
	public inline function once(f : T->Void):Void {
		listen(f, true);
	}

	/**
	  * Listen for data which passes [test] on [this] Signal
	  */
	public function when(test:T->Bool, f:T->Void):Void {
		add(Tested(f, test));
	}

	/**
	  * check for presence of given function as listener
	  */
	public function hasListener(f : T->Void):Bool {
	    for (h in handlers) {
	        switch ( h ) {
				case Normal( func ), Once( func ), Tested(func, _):
					return !Reflect.compareMethods(f, func);
				default:
				    continue;
	        }
	    }
	    return false;
	}

	/**
	  * Remove a listener
	  */
	public function ignore(func : T->Void):Void {
		handlers = handlers.filter(function(h : Handler<T>):Bool {
			switch (h) {
				/* Standard Handler */
				case Normal( f ), Once( f ), Tested(f, _):
					return !Reflect.compareMethods(f, func);

				/* Anything Else */
				default:
					return true;
			}
		});
	}

	/**
	  * Alias to 'ignore'
	  */
	public inline function off(f : T->Void):Void {
		ignore( f );
	}

	/**
	  * Clear [this] Signal of all Handlers
	  */
	public inline function clear():Void {
		handlers = new Array();
	}

	/**
	  * Call a listener
	  */
	private function callHandler(h:Handler<T>, arg:T):Void {
		switch (h) {
			/* Standard Handler */
			case Normal( f ):
				f( arg );

			/* Once Handler */
			case Once( func ):
                func( arg );

			/* Tested Handler */
			case Tested(f, test):
				if (test(arg)) {
					f( arg );
				}
		}
	}

	/**
	  * Call all listeners
	  */
	public function broadcast(data : T):Void {
		/* invoke the relevant handlers */
		var _handlers = [];
		for (h in handlers) {
			callHandler(h, data);
			if (!h.match(Once(_)))
			    _handlers.push( h );
		}
		handlers = _handlers;
	}

	/**
	  * Alias to 'broadcast'
	  */
	public inline function call(data : T):Void {
		broadcast(data);
	}

	/**
	  * get the number of handlers attached to [this] Signal
	  */
	public inline function listenerCount():Int {
	    return handlers.length;
	}

	/**
	  * check whether there is at least one listener attached to [this]
	  */
	public inline function hasListeners():Bool {
	    return (listenerCount() > 0);
	}

/* === Instance Fields === */

	/* The Handlers attached to [this] Signal */
	public var handlers:Array<Handler<T>>;

	/* Function invoked when [this] Signal is 'delete'd */
	public var ondelete : Void->Void;
}

private enum Handler<T> {
	/* Handler which can fire any number of times */
	Normal(func : T->Void);

	/* Handler which only fires once */
	Once(func: T->Void);

	/* Handler which only fires when the data passed to it matches [test] */
	Tested(func:T->Void, test:T->Bool);
}
