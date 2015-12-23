package tannus.css;

import tannus.css.*;
import tannus.ds.Object;
import tannus.io.VoidSignal;
import tannus.io.ByteArray;

class StyleSheet {
	/* Constructor Function */
	public function new():Void {
		rules = new Array();
		_update = new VoidSignal();
	}

/* === Instance Methods === */

	/**
	  * creates (when necessary) and returns a Rule
	  */
	public function rule(selector:String, ?props:Object):Rule {
		var r : Rule;

		// if that rule already exists
		if (hasRule(selector)) {
			// just return it
			r = getRule(selector);
		}
		// otherwise
		else {
			// create a new one
			r = new Rule(this, selector);
			// and return that
			rules.push( r );
			changed();
		}

		// if properties to add to [r] were provided
		if (props != null) {
			for (p in props.pairs()) {
				r.set(p.name, p.value);
			}
			changed();
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

	/**
	  * obtain a ByteArray representation of [this] StyleSheet
	  */
	public function toByteArray():ByteArray {
		var w = new Writer();
		return w.generate( this );
	}

	/**
	  * announce that a change has been made to [this] sheet
	  */
	private inline function changed():Void {
		_update.fire();
	}

	/**
	  * listen for changes to [this] sheet
	  */
	public inline function onchange(cb : Void->Void):Void {
		_update.on( cb );
	}

/* === Instance Fields === */

	/* The Array of Rules Associated with [this] StyleSheet */
	public var rules : Array<Rule>;

	/* signal fired when [this] StyleSheet changes */
	private var _update : VoidSignal;
}
