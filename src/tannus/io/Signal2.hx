package tannus.io;

import tannus.io.Ptr;

class Signal2<A, B> {
	/* Constructor Function */
	public function new():Void {
		handlers = new Array();
	}

/* === Instance Methods === */

	/**
	  * Adds a new Handler to the list of Handlers
	  */
	private inline function add(handler : Handler<A, B>):Void {
		handlers.push( handler );
	}

	/**
	  * Listen for data on [this] Signal
	  */
	public function listen(f:A->B->Void, once:Bool=false):Void {
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
	public inline function on(f:A->B->Void, once:Bool=false):Void {
		listen(f, once);
	}

	/**
	  * Listen for data on [this] Signal, only once
	  */
	public inline function once(f : A->B->Void):Void {
		listen(f, true);
	}

	/**
	  * Listen for data which passes [test] on [this] Signal
	  */
	public function when(test:A->B->Bool, f:A->B->Void):Void {
		add(Tested(f, test));
	}

	/**
	  * Remove a listener
	  */
	public function ignore(func : A->B->Void):Void {
		var toIgnore:Array<Handler<A, B>> = [];

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
	public inline function off(f : A->B->Void):Void {
		ignore( f );
	}

	/**
	  * Call a listener
	  */
	private function callHandler(h:Handler<A, B>, a:A, b:B):Void {
		switch (h) {
			/* Standard Handler */
			case Normal( f ):
				f(a, b);

			/* Once Handler */
			case Once(f, fired):
				//- if [this] Handler has been fired
				if (!fired.v) {
					f(a, b);
					fired &= true;
				}

			/* Aested Handler */
			case Tested(f, test):
				if (test(a, b)) {
					f(a, b);
				}
		}
	}

	/**
	  * Call all listeners
	  */
	public function broadcast(a:A, b:B):Void {
		for (h in handlers) {
			callHandler(h, a, b);
		}
	}

	/**
	  * Alias to 'broadcast'
	  */
	public inline function call(a:A, b:B):Void {
		broadcast(a, b);
	}

/* === Instance Fields === */

	/* Ahe Handlers attached to [this] Signal */
	public var handlers:Array<Handler<A, B>>;
}

private enum Handler<A, B> {
	/* Handler which can fire any number of times */
	Normal(func : A->B->Void);

	/* Handler which only fires once */
	Once(func:A->B->Void, fired:Ptr<Bool>);

	/* Handler which only fires when the data passed to it matches [test] */
	Tested(func:A->B->Void, test:A->B->Bool);
}
