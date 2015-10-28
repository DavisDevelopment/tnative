package tannus.css;

import tannus.css.*;
import tannus.ds.Object;

class StyleSheet {
	/* Constructor Function */
	public function new():Void {
		rules = new Array();
	}

/* === Instance Methods === */

	/**
	  * Adds a Rule to [this] Sheet
	  */
	public function rule(selector:String, ?props:Object):Rule {
		var r : Rule;

		if (hasRule(selector))
			r = getRule(selector);
		else {
			r = new Rule(this, selector);
			rules.push( r );
		}

		if (props != null) {
			for (p in props.pairs()) {
				r.set(p.name, p.value);
			}
		}

		return r;
	}

	/**
	  * Determine whether [this] StyleSheet has a Rule with the given selector
	  */
	public function hasRule(sel : String):Bool {
		return (getRule(sel) != null);
	}

	/**
	  * Obtain the Rule with the given name
	  */
	private function getRule(sel : String):Null<Rule> {
		for (rule in rules)
			if (rule.selector == sel)
				return rule;
		return null;
	}

	/**
	  * Obtain the String Representation of [this] StyleSheet
	  */
	public function toString():String {
		var w = new Writer();
		return w.generate( this );
	}

/* === Instance Fields === */

	/* The Array of Rules Associated with [this] StyleSheet */
	public var rules : Array<Rule>;
}
