package tannus.events;

import tannus.io.Ptr;
import tannus.io.Signal;
import tannus.ds.Maybe;

import tannus.geom.*;

@:allow(tannus.events.EventCreator)
class Event {
	/* Constructor Function */
	public function new(variety:String, bubbls:Bool=false):Void {
		type = variety;
		_bubbles = bubbls;
		_defaultPrevented = false;

		onDefaultPrevented = new Signal();
		onPropogationStopped = new Signal();
	}

/* === Instance Methods === */

	/**
	  * Prevent the default action of [this] Event
	  */
	public function preventDefault():Void {
		_defaultPrevented = true;
		onDefaultPrevented.broadcast( defaultPrevented );
	}

	/**
	  * Stop the propogation of [this] Event
	  */
	public function stopPropogation():Void {
		onPropogationStopped.broadcast( true );
	}

/* === Computed Instance Fields === */

	/**
	  * 'bubbles' field
	  */
	public var bubbles(get, never):Bool;
	private inline function get_bubbles() return (_bubbles);

	/**
	  * Whether [this] Event has had it's default action prevented
	  */
	public var defaultPrevented(get, never):Bool;
	private inline function get_defaultPrevented() return (_defaultPrevented);

/* === Instance Fields === */

	//- The type of Event [this] is
	public var type:String;

	//- Whether [this] Event bubbles
	private var _bubbles:Bool;

	//- Whether [this] Event has had it's default action prevented
	private var _defaultPrevented:Bool;

	//- Signal which fires when [this] Event's default action is prevented
	private var onDefaultPrevented:Signal<Dynamic>;

	//- Signal which fires when [this] Event's propogation is stopped
	private var onPropogationStopped:Signal<Dynamic>;
}
