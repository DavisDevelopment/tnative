package tannus.html;

import tannus.ds.Maybe;
import tannus.ds.Object;
import tannus.io.Ptr;

import tannus.html.ElStyles;

import js.JQuery;

@:forward
abstract Element (JQuery) from JQuery {
	/* Constructor Function */
	public inline function new(jq : Dynamic):Void {
		this = new JQuery(jq);
	}

/* === Instance Fields === */

	/**
	  * Determine whether any actual Elements are currently being referenced
	  */
	public var exists(get, never):Bool;
	private inline function get_exists() {
		return (this.length > 0);
	}

	/**
	  * textual value of [this] Element, as a field
	  */
	public var text(get, set):String;
	private inline function get_text() return (this.text());
	private inline function set_text(nt:String) {
		this.text( nt );
		return text;
	}

	/**
	  * Map-Like Access to the css-styles of [this] Element
	  */
	public var style(get, never):ElStyles;
	private function get_style():ElStyles {
		return new ElStyles(_cs.bind(_));
	}

	/* Utility Function, only used for the [style] field */
	private function _cs(args : Array<String>):String {
		var r:Maybe<String> = cs(args[0], args[1]);
		return (r || '');
	}

	/**
	  * More intuitive version of JQuery.css(k, v)
	  */
	private function cs(k:String, ?v:Maybe<String>):Maybe<String> {
		if (v) {
			this.css(k, v);
		}
		return this.css(k);
	}

/* === Instance Methods === */

	/**
	  * Get attribute
	  */
	@:arrayAccess
	public inline function get(key : String):Maybe<String> {
		return (this.attr(key));
	}

	/**
	  * Set attribute
	  */
	@:arrayAccess
	public inline function set(key:String, value:String):String {
		this.attr(key, value);
		return value;
	}

/* === Type Casting === */

	/* To Array of ELements */
	@:to
	public inline function toArray():Array<Element> {
		return (this.toArray().map(function(e) return new Element(e)));
	}

	/* From String */
	@:from
	public static inline function fromString(q : String):Element {
		return new Element(q);
	}
}
