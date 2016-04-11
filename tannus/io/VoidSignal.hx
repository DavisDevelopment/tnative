package tannus.io;

import tannus.io.Ptr;

class VoidSignal {
	/* Constructor Function */
	public function new():Void {
		handlers = new Array();
		ondelete = (function() null);
		_remove = new Array();
	}

/* === Instance Methods === */

	/**
	  * Create and return a clone of [this] Signal
	  */
	public function clone():VoidSignal {
		var c = new VoidSignal();
		for (h in handlers) {
			switch ( h ) {
				case Normal( f ):
					c.add(Normal(f.bind()));

				case Counted(f, count, fired):
					c.add(Counted(f.bind(), count, Ptr.to( fired )));

				case Once(f, fired):
					if ( !fired._ ) {
						c.add(Once(f.bind(), Ptr.to( false )));
					}

				case Every(f, wait, remaining):
					c.add(Every(f.bind(), wait, Ptr.to( remaining )));
			}
		}
		return c;
	}

	/* Adds a new Handler to the List */
	private inline function add(h : Handler):Void {
		handlers.push( h );
	}

	/**
	  * Listen for [this] Signal
	  */
	public function on(f : Void->Void):Void {
		add(Normal( f ));
	}

	/**
	  * Listen for [this] Signal, only once
	  */
	public function once(f : Void->Void):Void {
		add(Once(f, Ptr.to(false)));
	}

	/**
	  * Listen for [this] Signal, [count] times
	  */
	public function times(count:Int, f:Void->Void):Void {
		add(Counted(f, count, Ptr.to(0)));
	}

	/**
	  * Listen for [this] Signal, every [interval] times it fires
	  */
	public function every(interval:Int, f:Void->Void):Void {
		add(Every(f, interval, Ptr.to(interval)));
	}

	/**
	  * Stop listening to [this] Signal
	  */
	public function ignore(func : Void->Void):Void {
		var ignores:Array<Handler> = new Array();
		for (h in handlers) switch ( h ) {
			case Normal(f), Once(f, _), Counted(f, _, _), Every(f, _, _):
				if (Reflect.compareMethods(f, func)) {
					ignores.push( h );
				}

			default:
				null;
		}
		for (h in ignores)
			handlers.remove( h );
	}

	/**
	  * Alias to 'ignore'
	  */
	public inline function off(f : Void->Void):Void {
		ignore( f );
	}

	/**
	  * Clear [this] Signal of all handlers
	  */
	public function clear():Void {
		handlers = new Array();
	}

	/**
	  * Call the given handler
	  */
	private function callHandler(h : Handler):Void {
		switch ( h ) {
			case Normal( f ):
				f();

			case Once(f, fired):
				if ( !fired._ ) {
					f();
					_remove.push( h );
				}

			case Counted(f, count, fired):
				if (fired._ < count) {
					f();
					fired.value += 1;
				}
				else {
					_remove.push( h );
				}

			case Every(f, wait, rem):
				if (rem == wait) {
					f();
					rem &= 0;
				} else rem.v += 1;
		}
	}

	/**
	  * Fire [this] Signal
	  */
	public function call():Void {
		for (h in handlers) {
			callHandler( h );
		}
		for (h in _remove)
			handlers.remove(h);
		_remove = new Array();
	}

	/**
	  * Alias to 'call'
	  */
	public inline function fire():Void {
		call();
	}

/* === Instance Fields === */

	private var handlers : Array<Handler>;
	private var ondelete : Void->Void;
	private var _remove : Array<Handler>;
}

/**
  * Enum of the types of Handlers which may be attached to [this] Shit
  */
private enum Handler {
	/* Handler which can fire any number of times */
	Normal(func : Void->Void);

	/* Handle which will only fire [count] times */
	Counted(func:Void->Void, count:Int, fired:Ptr<Int>);

	/* Handler which will only fire every [rem] times */
	Every(func:Void->Void, wait:Int, remaining:Ptr<Int>);

	/* Handler which only fires once */
	Once(func:Void->Void, fired:Ptr<Bool>);
}
