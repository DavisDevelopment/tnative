package tannus.io;

import tannus.io.Ptr;

class Signal<T> {
	/* Constructor Function */
	public function new():Void {
		handlers = new Array();
		ondelete = (function() null);
	}

/* === Instance Methods === */

	/**
	  * Adds a new Handler to the list of Handlers
	  */
	private inline function add(handler : Handler<T>):Void {
		handlers.push( handler );
	}

	/**
	  * Listen for data on [this] Signal
	  */
	public function listen(f:T->Void, once:Bool=false):Void {
		if (!once) {
			add(Normal(f));
		} else {
			var _fired:Bool = false;
			var fired:Ptr<Bool> = Ptr.create(_fired);
			add(Once(f, fired));
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
	  * Remove a listener
	  */
	public function ignore(func : T->Void):Void {
		var toIgnore:Array<Handler<T>> = [];

		for (h in handlers) {
			switch (h) {
				/* Standard Handler */
				case Normal( f ), Once(f, _), Tested(f, _):
					/* if [f] and [func] are the same function */
					if (Reflect.compareMethods(f, func)) {
						//- flag it for removal
						toIgnore.push(h);
					}

				/* Anything Else */
				default:
					//- Do Nothing
					null;
			}
		}

		for (h in toIgnore)
			handlers.remove( h );
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
			case Once(f, fired):
				//- if [this] Handler has been fired
				if (!fired.v) {
					f( arg );
					fired &= true;
				}

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
		for (h in handlers) {
			callHandler(h, data);
		}
	}

	/**
	  * Alias to 'broadcast'
	  */
	public inline function call(data : T):Void {
		broadcast(data);
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
	Once(func:T->Void, fired:Ptr<Bool>);

	/* Handler which only fires when the data passed to it matches [test] */
	Tested(func:T->Void, test:T->Bool);
}
