package tannus.html;

import tannus.io.Getter;
import tannus.html.Element;
import tannus.ds.Object;
import tannus.ds.Dict;

import js.html.Element in El;
import js.html.NamedNodeMap;
import js.html.Attr;
import Std.*;

using Lambda;

abstract ElAttributes (Getter<Element>) {
	/* Constructor Function */
	public inline function new(ref : Getter<Element>):Void {
		this = ref;
	}

/* === Instance Methods === */

	/**
	  * Get the value of an attribute
	  */
	@:arrayAccess
	public function getAttribute(name : String):String {
		return elem.attr(name);
	}

	/**
	  * Set the value of an attribute
	  */
	@:arrayAccess
	public function setAttribute<T>(name:String, value:T):String {
		elem.attr(name, string(value));
		return getAttribute(name);
	}

	/**
	  * Set an Object of attributes
	  */
	@:op(A += B)
	public function writeObject(o : Object):Void {
		for (p in o.pairs()) {
			elem[p.name] = string(p.value);
		}
	}

	/**
	  * Get an Object of all attributes
	  */
	@:to
	public function toObject():Object {
		var o:Object = new Object({});
		var list:NamedNodeMap = el.attributes;
		for (i in 0...list.length) {
			var p = list.item(i);
			o[p.name] = p.value;
		}
		return o;
	}

	/**
	  * Get a Dict of all attributes
	  */
	@:to
	public function toDict():Dict<String, String> {
		var d:Dict<String, String> = new Dict();
		var list = el.attributes;
		for (i in 0...list.length) {
			var p = list.item(i);
			d[p.name] = p.value;
		}
		return d;
	}

/* === Instance Fields === */

	/**
	  * internal reference to the Element [this] references
	  */
	private var elem(get, never):Element;
	private inline function get_elem() return (this.v);

	/**
	  * internal reference to the Element as a js.html.Element
	  */
	private var el(get, never):El;
	private inline function get_el() return (elem.toHTMLElement());
}
