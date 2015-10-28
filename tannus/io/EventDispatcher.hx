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
	  * Determine if [this] Dispatcher is prepared to dispatch an Event by the given name
	  */
	public function canDispatch(name : String):Bool {
		return _sigs.exists(name);
	}

	/**
	  * Listen for an Event on [this] Dispatcher
	  */
	public function on<T>(name:String, action:T->Void, ?once:Bool):Void {
		if (canDispatch(name)) {
			_sigs[name].on(cast action, once);
		} else {
			throw 'InvalidEvent: "$name" is not a valid Event';
		}
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
		if (canDispatch(name)) {
			_sigs[name].call(untyped data);
		}
	}

	/**
	  * Stop listening for an Event
	  */
	public function off(name:String, ?action:Dynamic->Void):Void {
		var sig:Signal<Dynamic> = _sigs[name];
		if (sig != null) {
			if (action != null)
				sig.off( action );
			else
				sig.clear();
		}
	}

	/**
	  * Listen for an event, conditionally
	  */
	public function when<T>(name:String, test:T->Bool, action:T->Void):Void {
		if (canDispatch(name)) {
			untyped {
				_sigs[name].when(test, action);
			};
		} else {
			throw 'InvalidEvent: "$name" is not a valid Event';
		}
	}

/* === Instance Fields === */

	private var _sigs:Map<String, Signal<Dynamic>>;
}
