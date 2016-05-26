package tannus.dom;

import tannus.dom.Element;

import js.html.NamedNodeMap;

import Std.*;

@:forward
abstract Attributes (CAttributes) from CAttributes to CAttributes {
	/* Constructor Function */
	public inline function new(e : Element):Void {
		this = new CAttributes( e );
	}

/* === Methods === */

	@:arrayAccess
	public inline function get(k : String):String return this.get(k);
	@:arrayAccess
	public inline function set(k:String, v:Dynamic):String return this.set(k, v);
}

class CAttributes {
	/* Constructor Function */
	public function new(e : Element):Void {
		element = e;
	}

/* === Instance Methods === */

	/**
	  * Check for the existence of the given attribute
	  */
	public function exists(name : String):Bool {
		return element.first.hasAttribute( name );
	}

	/**
	  * Get the value of an attribute
	  */
	public function get(name : String):String {
		return element.first.getAttribute( name );
	}

	/**
	  * Set the value of an attribute
	  */
	public function set(name:String, value:Dynamic):String {
		for (e in element.els) {
			e.setAttribute(name, string(value));
		}
		return string( value );
	}

	/**
	  * Delete an attribute
	  */
	public function remove(name : String):Void {
		for (e in element.els) {
			e.removeAttribute( name );
		}
	}

/* === Instance Fields === */

	private var element : Element;
}
