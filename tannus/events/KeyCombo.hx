package tannus.events;

import tannus.events.KeyboardEvent;
import tannus.events.kc.KeyCheck;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;
using tannus.events.kc.KeyCheckTools;

class KeyCombo {
	/* Constructor Function */
	public function new(desc : String):Void {
		description = desc;
	}

/* === Instance Methods === */

	/**
	  * test [event]
	  */
	public function test(event : KeyboardEvent):Bool {
		for (c in checks) {
			if (!c.test( event )) {
				return false;
			}
		}
		return checks.isAllModsTested( event );
	}

	/**
	  * get [this]'s description, pretty-printed
	  */
	public function getDescription():String {
		var parts = new Array();
		for (check in checks) {
			switch ( check ) {
				case KCMod( mod ):
					parts.push((mod + '').capitalize());

				case KCKey( key ):
					parts.push(key.name.capitalize( true ));
			}
		}
		return parts.join( '+' );
	}

	/**
	  * convert [this] to a String
	  */
	public function toString():String {
		return 'KeyCombo(${getDescription()})';
	}

/* === Computed Instance Fields === */

	/* the description of [this] Combo */
	public var description(default, set):String;
	private function set_description(v : String):String {
		checks = v.toKeyChecks();
		return (description = v);
	}

/* === Instance Fields === */

	public var checks : Array<KeyCheck>;

/* === Static Methods === */

	/**
	  * Create a KeyCombo from the given KeyboardEvent
	  */
	public static function ofEvent(event : KeyboardEvent):KeyCombo {
		var parts:Array<String> = new Array();

		if ( event.ctrlKey ) {
			parts.push( 'Ctrl' );
		}
		if ( event.metaKey ) {
			parts.push( 'Super' );
		}
		if ( event.shiftKey ) {
			parts.push( 'Shift' );
		}
		if ( event.altKey ) {
			parts.push( 'Alt' );
		}
		
		parts.push( event.key.name );

		return new KeyCombo(parts.join( '+' ));
	}
}
