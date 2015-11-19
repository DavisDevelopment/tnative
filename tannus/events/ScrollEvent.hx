package tannus.events;

import tannus.events.Event;
import tannus.events.EventMod;

class ScrollEvent extends Event {
	/* Constructor Function */
	public function new(delt : Int):Void {
		super( 'scroll' );

		delta = delt;
	}

/* === Instance Fields === */

	public var delta : Int;
}
