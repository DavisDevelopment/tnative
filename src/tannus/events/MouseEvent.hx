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

/* === Instance Fields === */

	//- The coordinates of the Mouse
	public var position : Point;

	//- The ID of the Button
	public var button : Int;

	//- The Array of all Event-Modifiers
	private var emods : Array<EventMod>;
}
