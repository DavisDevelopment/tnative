package tannus.css;

import tannus.css.*;
import tannus.ds.Object;

using tannus.ds.ArrayTools;

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

		var kid = sheet.rule(sel, props);
		kid.parentRule = this;
		return kid;
	}

	/**
	  * Add a Property to [this] Rule
	  */
	public function set(name:String, value:Dynamic):Void {
		if (exists( name )) {
			var p = getProp(name);
			p.value = Std.string( value );
		}
		else {
			var p = new Property(name, Std.string(value));
			properties.push( p );
		}
		changed();
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

	/* get the Property object for the given property */
	public function property(name : String):Property {
		var p:Property = getProp( name );
		if (p == null) {
			p = new Property(name, '');
			properties.push( p );
		}
		return p;
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

	/**
	  * create and return a clone of [this] Rule
	  */
	public inline function clone(?nsheet : StyleSheet):Rule {
		return new Rule((nsheet != null ? nsheet : sheet), selector, properties.macmap(_.clone()));
	}

	/**
	  * announce a change to [this] rule
	  */
	private inline function changed():Void {
		sheet.changed();
	}

/* === Instance Fields === */

	public var selector : String;
	public var sheet : StyleSheet;
	public var properties : Array<Property>;

	public var parentRule : Null<Rule> = null;
}
