package tannus.events;

import tannus.events.Event;
import tannus.events.EventMod;
import tannus.events.Key;

using Lambda;
class KeyboardEvent extends Event {
	/* Constructor Function */
	public function new(type:String, code:Int, ?emods:Array<EventMod>):Void {
		super( type );
		
		keyCode = code;
		key = keyCode;
		mods = (emods!=null?emods:[]);
		altKey = mods.has(Alt);
		ctrlKey = mods.has(Control);
		shiftKey = mods.has(Shift);
		metaKey = mods.has(Meta);
	}

/* === Instance Fields === */

	public var keyCode : Int;
	public var key : Key;
	private var mods : Array<EventMod>;
	public var altKey : Bool;
	public var ctrlKey : Bool;
	public var shiftKey : Bool;
	public var metaKey : Bool;

/* === Static Methods === */

	/**
	  * Create a tannus KeyboardEvent from a jQuery one
	  */
	public static function fromJqEvent(e : js.JQuery.JqEvent):KeyboardEvent {
		var mods:Array<EventMod> = new Array();
		if (e.altKey) mods.push( Alt );
		if (e.ctrlKey) mods.push( Control );
		if (e.shiftKey) mods.push( Shift );
		if (e.metaKey) mods.push( Meta );
		var res = new KeyboardEvent(e.type, e.keyCode, mods);
		res.onDefaultPrevented.once(untyped e.preventDefault);
		res.onPropogationStopped.once(untyped e.stopPropagation);
		return res;
	}
}
