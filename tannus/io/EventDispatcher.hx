package tannus.io;

import tannus.io.Ptr;
import tannus.io.Signal;
import tannus.ds.Maybe;

class EventDispatcher {
	/* Constructor Function */
	public function new():Void {
		_sigs = new Map();
	}

/* === Instance Methods === */

	/**
	  * Add a new Signal to [this] Dispatcher
	  */
	public function addSignal(name:String, ?sig:Maybe<Signal<Dynamic>>):Void {
		_sigs[name] = sig.or(new Signal());
	}

	/**
	  * Add a list of Signals to [this] Dispatcher
	  */
	public inline function addSignals(names : Array<String>):Void {
		for (name in names)
			addSignal( name );
	}

	/**
	  * get a Signal
	  */
	private function getSignal(name:String, create:Bool=true):Maybe<Signal<Dynamic>> {
		if (!canDispatch( name )) {
			if ( __checkEvents ) {
				throw 'InvalidEvent: "$name" is not a valid Event';
			}
			else if ( create ) {
				_sigs[name] = new Signal();
			}
		}
		return _sigs[ name ];
	}

	/**
	  * Determine if [this] Dispatcher is prepared to dispatch an Event by the given name
	  */
	public function canDispatch(name : String):Bool {
		return _sigs.exists(name);
	}

	/**
	  * Listen for an Event on [this] Dispatcher
	  */
	public function on<T>(name:String, action:T->Void, ?once:Bool):Void {
		getSignal( name ).on(cast action, once);
	}

	/**
	  * Listen for an Event, only once
	  */
	public function once<T>(name:String, action:T->Void):Void {
		on(name, action, true);
	}

	/**
	  * Dispatch an Event on [this] Shit
	  */
	public function dispatch<T>(name:String, data:T):Void {
		getSignal( name ).call(untyped data);
	}

	/**
	  * Stop listening for an Event
	  */
	public function off(name:String, ?action:Dynamic->Void):Void {
		var sig:Signal<Dynamic> = getSignal( name );
		if (action != null)
			sig.off( action );
		else
			sig.clear();
		if (!sig.hasListeners())
		    _sigs.remove( name );
	}

	/**
	  * Listen for an event, conditionally
	  */
	public function when<T>(name:String, test:T->Bool, action:T->Void):Void {
		untyped {
			getSignal( name ).when(test, action);
		};
	}

	/**
	  * check whether an event has any listeners attached to it
	  */
	public function hasListener<T>(name:String, ?l:T->Void):Bool {
	    var sig = getSignal(name, false);
	    if (sig == null)
	        return false;
        else {
            return sig.ternary(l != null ? _.hasListener( l ) : _.hasListeners(), false);
        }
	}

/* === Instance Fields === */

	private var _sigs:Map<String, Signal<Dynamic>>;
	private var __checkEvents : Bool = true;
}
