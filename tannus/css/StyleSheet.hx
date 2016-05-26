package tannus.css;

import tannus.css.*;
import tannus.ds.Object;
import tannus.io.VoidSignal;
import tannus.io.ByteArray;

using tannus.ds.ArrayTools;

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
	public function getRule(sel : String):Null<Rule> {
		for (rule in rules)
			if (rule.selector == sel)
				return rule;
		return null;
	}

	/**
	  * Add a @font-face Rule to [this] StyleSheet
	  * this method bypasses the standard procedure of merging rules with the same selector
	  */
	public function fontFace(family:String, source:String):FontFace {
		var r:Rule = new Rule(this, '@font-face');
		r.set('font-family', family);
		r.set('src', 'url("$source")');
		rules.push( r );
		changed();
		return r;
	}

	/**
	  * Get the FontFace with the provided name
	  */
	public function getFontFace(family : String):Null<FontFace> {
		for (font in getAllFontFaces()) {
			if (font.family == family) {
				return font;
			}
		}
		return null;
	}

	/**
	  * Check whether a FontFace exists with the given name
	  */
	public function hasFontFace(name : String):Bool {
		return (getFontFace( name ) != null);
	}

	/**
	  * Get all FontFace Rules
	  */
	public function getAllFontFaces():Array<FontFace> {
		return rules.macfilter(_.selector == '@font-face');
	}

	/**
	  * Create and return a clone of [this] StyleSheet
	  */
	public function clone():StyleSheet {
		var c = new StyleSheet();
		c.rules = rules.macmap(_.clone( c ));
		return c;
	}

	/**
	  * get (effectively) the sum of [this] StyleSheet and [other]
	  */
	public function concat(other : StyleSheet):StyleSheet {
		var sum = new StyleSheet();
		for (r in rules.concat(other.rules)) {
			sum.rules.push(r.clone( sum ));
		}
		return sum;
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

/* === Static Methods === */

	/**
	  * Create a StyleSheet from the given css-code
	  */
	public static inline function fromCSS(code : String):StyleSheet {
		return Parser.quickParse(Lexer.quickLex( code ));
	}
}
