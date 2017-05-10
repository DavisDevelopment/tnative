package tannus.events;

import tannus.ds.Maybe;
import tannus.geom.Point;

import tannus.events.Event;
import tannus.events.EventMod;

using Lambda;
class MouseEvent extends Event {
	/* Constructor Function */
	public function new(type:String, pos:Point, ?btn:Int=-1, ?mods:Maybe<Array<EventMod>>=null):Void {
		super( type );

		position = pos;
		button = btn;
		emods = mods.or([]);
	}

/* === Instance Methods === */

	/**
	  * create and return a clone of [this]
	  */
	override public function clone(deep:Bool=false):Event {
		return new MouseEvent(type, position.clone(), button, emods);
	}

/* === Computed Instance Fields === */

	/* ShiftKey Mod */
	public var shiftKey(get, never):Bool;
	private inline function get_shiftKey() return emods.has(Shift);

	/* AltKey Mod */
	public var altKey(get, never):Bool;
	private inline function get_altKey() return emods.has(Alt);

	/* CtrlKey Mod */
	public var ctrlKey(get, never):Bool;
	private inline function get_ctrlKey() return emods.has(Control);

	/* MetaKey Mod */
	public var metaKey(get, never):Bool;
	private inline function get_metaKey() return emods.has(Meta);

	public var noMods(get, never):Bool;
	private inline function get_noMods() return !(shiftKey||altKey||ctrlKey||metaKey);

/* === Instance Fields === */

	//- The coordinates of the Mouse
	public var position : Point;

	//- The ID of the Button
	public var button : Int;

	//- The Array of all Event-Modifiers
	private var emods : Array<EventMod>;

/* === Static Methods === */

	/**
	  * Create a Tannus MouseEvent from a jQuery MouseEvent
	  */
	public static function fromJqEvent(event : js.jquery.Event):MouseEvent {
		var mods:Array<EventMod> = new Array();
		if (event.shiftKey)
			mods.push( Shift );
		if (event.altKey)
			mods.push( Alt );
		if (event.ctrlKey)
			mods.push( Control );
		if (event.metaKey)
			mods.push( Meta );
		var pos = new Point(event.pageX, event.pageY);
		
		var e = new MouseEvent(event.type, pos, Std.int( event.which ), mods);
		e.onCancelled.once(event.preventDefault);
		e.onDefaultPrevented.once(event.preventDefault);
		e.onPropogationStopped.once(event.stopPropagation);
		function copyEvent(copy : Event):Void {
			copy.onCancelled.once(event.preventDefault);
			copy.onDefaultPrevented.once(event.preventDefault);
			copy.onPropogationStopped.once(event.stopPropagation);
			copy._onCopy.on( copyEvent );
		}
		e._onCopy.on( copyEvent );

		return e;
	}

	/**
	  * Create a Tannus MouseEvent from a native JavaScript MouseEvent
	  */
	public static function fromJsEvent(event : js.html.MouseEvent):MouseEvent {
		var mods:Array<EventMod> = new Array();
		if (event.shiftKey)
			mods.push( Shift );
		if (event.altKey)
			mods.push( Alt );
		if (event.ctrlKey)
			mods.push( Control );
		if (event.metaKey)
			mods.push( Meta );
		var pos = new Point(event.pageX, event.pageY);
		
		var e = new MouseEvent(event.type, pos, event.which, mods);
		e.onCancelled.once(event.preventDefault);
		e.onDefaultPrevented.once(event.preventDefault);
		e.onPropogationStopped.once(event.stopPropagation);
		function copyEvent(copy : Event):Void {
			copy.onCancelled.once(event.preventDefault);
			copy.onDefaultPrevented.once(event.preventDefault);
			copy.onPropogationStopped.once(event.stopPropagation);
			copy._onCopy.on( copyEvent );
		}
		e._onCopy.on( copyEvent );

		return e;
	}
}
