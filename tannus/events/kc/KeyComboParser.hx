package tannus.events.kc;

import tannus.events.KeyboardEvent;
import tannus.events.kc.KeyCheck;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;
using tannus.events.kc.KeyCheckTools;
using tannus.events.KeyTools;

class KeyComboParser {
	/* Constructor Function */
	public function new():Void {
		checks = new Array();
		tests = new Array();
	}

/* === Instance Methods === */

	/**
	  * Parse the given String
	  */
	public function parseString(s : String):Void {
		var tokens:Array<String> = s.toLowerCase().split('+').macfilter(!_.trim().empty());
		for (token in tokens) {
			var check = parseCheck( token );
			checks.push( check );
		}
	}

	/**
	  * Parse a String into a Check
	  */
	private function parseCheck(token : String):KeyCheck {
		switch ( token ) {
			case 'ctrl':
				return KCMod( Control );
			case 'alt':
				return KCMod( Alt );
			case 'shift':
				return KCMod( Shift );
			case 'meta', 'super':
				return KCMod( Meta );
			default:
				var key = token.getKey();
				if (key != null) {

				}
		}
	}

/* === Instance Fields === */

	public var checks : Array<KeyCheck>;
	public var tests : Array<EventTest>;
}

typedef EventTest = KeyboardEvent -> Bool;
