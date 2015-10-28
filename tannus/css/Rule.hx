package tannus.css;

import tannus.css.*;
import tannus.ds.Object;

@:access(tannus.css.StyleSheet)
class Rule {
	/* Constructor Function */
	public function new(par:StyleSheet, sel:String, ?props:Array<Property>):Void {
		sheet = par;
		selector = sel;
		properties = (props != null ? props : new Array());
	}

/* === Instance Methods === */

	/**
	  * Add a Child Rule to [this] one
	  */
	public function child(childSel:String, ?props:Object):Rule {
		var sel:String = [selector, ' ', childSel].join('');

		return sheet.rule(sel, props);
	}

	/**
	  * Add a Property to [this] Rule
	  */
	public function set(name:String, value:Dynamic):Void {
		properties.push(new Property(name, Std.string(value)));
	}

	/**
	  * Determine whether [this] Rule has a Property with the given name
	  */
	public function exists(name : String):Bool {
		return (getProp(name) != null);
	}

	/**
	  * Get the value of Property [name]
	  */
	public function get(name : String):Null<String> {
		if (exists(name)) {
			return (getProp(name).value);
		}
		else return null;
	}

	/**
	  * Get a Property
	  */
	private function getProp(name : String):Null<Property> {
		for (prop in properties) {
			if (prop.name == name)
				return prop;
		}
		return null;
	}

/* === Instance Fields === */

	public var selector : String;
	public var sheet : StyleSheet;
	public var properties : Array<Property>;
}
