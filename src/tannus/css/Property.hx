package tannus.css;

import tannus.css.Value;
import tannus.css.vals.Lexer.parseString;

class Property {
	/* Constructor Function */
	public function new(key:String, val:String):Void {
		name = key;
		value = val;
	}

/* === Computed Instance Fields === */

	/**
	  * The value of [this] Property, as an Array of Value's
	  */
	public var values(get, never):Array<Value>;
	private function get_values() {
		return parseString(value);
	}

/* === Instance Fields === */

	public var name : String;
	public var value : String;
}
