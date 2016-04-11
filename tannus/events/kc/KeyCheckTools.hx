package tannus.events.kc;

import tannus.events.Key;
import tannus.events.KeyboardEvent;
import tannus.events.EventMod;
import tannus.io.RegEx;

import tannus.events.kc.KeyCheck;
import tannus.events.KeyTools;

using Lambda;
using tannus.ds.ArrayTools;
using StringTools;
using tannus.ds.StringUtils;
using tannus.ds.MapTools;
using tannus.events.KeyTools;

class KeyCheckTools {
	/**
	  * test the given Event against the given KeyCheck
	  */
	public static function test(check:KeyCheck, event:KeyboardEvent):Bool {
		switch ( check ) {
			case KCKey( key ):
				return (event.key == key);

			case KCMod( mod ):
				for (m in event.getModifiers()) {
					if (m ==  mod) {
						return true;
					}
				}
				return false;
		}
	}

	/**
	  * ensure that the EventMods tested for are the only EventMods present on the given Event
	  */
	public static function isAllModsTested(checks:Array<KeyCheck>, event:KeyboardEvent):Bool {
		var checkedMods:Array<EventMod> = new Array();
		for (c in checks) switch ( c ) {
			case KCKey(_): null;
			case KCMod( mod ):
				checkedMods.push( mod );
		}
		var presentMods:Array<EventMod> = event.getModifiers();
		var unchecked = presentMods.without( checkedMods );
		return unchecked.empty();
	}

	/**
	  * parse the given String into an Array of KeyChecks
	  */
	public static function toKeyChecks(str : String):Array<KeyCheck> {
		var pieces:Array<String> = str.split( '+' ).macmap(_.trim()).macfilter(!_.empty());
		var checks:Array<KeyCheck> = new Array();
		var mods:Map<String, EventMod> = [
			'alt' => Alt,
			'shift' => Shift,
			'ctrl' => Control,
			'super' => Meta,
			'meta' => Meta
		];

		for (s in pieces) {
			/* == mod == */
			if (mods.keyArray().has(s.toLowerCase())) {
				checks.push(KCMod(mods[s.toLowerCase()]));
			}

			/* == normal key == */
			else {
				/* single letter */
				if (s.length == 1) {
					checks.push(KCKey(s.charCodeAt( 0 )));
				}
				else {
					checks.push(KCKey(KeyTools.getKey( s )));
				}
			}
		}

		return checks;
	}
}
