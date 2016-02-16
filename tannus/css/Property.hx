package tannus.css;

import tannus.css.Value;
import tannus.css.vals.Lexer.parseString;

using tannus.ds.ArrayTools;
using tannus.css.vals.ValueTools;

class Property {
	/* Constructor Function */
	public function new(key:String, val:String):Void {
		name = key;
		value = val;
	}

/* === Instance Methods === */

	/**
	  * Set the value of [this] Property by an Array<Value> object
	  */
	public function setValues(val : Array<Value>):String {
		var hunks:Array<String> = val.macmap(_.toString());
		
		return (value = hunks.join(' '));
	}

	/**
	  * create and return a clone of [this] Property
	  */
	public inline function clone():Property {
		return new Property(name, value);
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
