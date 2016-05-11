package tannus.html;

import tannus.io.Getter;
import tannus.io.Ptr;
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

	/* obtain a reference to an attribute by name */
	public inline function reference(name : String):ElAttr {
		return ElAttr.fromAttr(el.attributes.getNamedItem( name ));
	}

	/**
	  * Get the value of an attribute
	  */
	@:arrayAccess
	public function get(name : String):String {
		return elem.attr( name );
	}

	/**
	  * Set the value of an attribute
	  */
	@:arrayAccess
	public function set<T>(name:String, value:T):String {
		elem.attr(name, string( value ));
		return get( name );
	}

	/**
	  * Delete an attribute
	  */
	public function remove(name : String):Bool {
		var had = el.hasAttribute( name );
		elem.removeAttr( name );
		return had;
	}

	public inline function exists(name : String):Bool {
		return el.hasAttribute( name );
	}

	/**
	  * Check whether the given attribute exists
	  */
	public inline function iterator():ElAttrIter {
		return new ElAttrIter(cast this);
	}

	public inline function names():Iterator<String> return new ElAttrNameIter(cast this);

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
	/*
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
	*/

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

@:access( tannus.html.ElAttributes )
class ElAttrIter {
	public function new(e : ElAttributes):Void {
		a = e.el.attributes;
		i = new IntIterator(0, a.length);
	}

	public inline function hasNext():Bool return i.hasNext();
	public inline function next():ElAttr {
		return ElAttr.fromAttr(a.item(i.next()));
	}

	private var a : NamedNodeMap;
	private var i : IntIterator;
}

@:access( tannus.html.ElAttributes )
class ElAttrNameIter {
	public function new(e : ElAttributes):Void {
		a = e.el.attributes;
		i = new IntIterator(0, a.length);
	}

	public inline function hasNext():Bool return i.hasNext();
	public inline function next():String {
		return a.item(i.next()).name;
	}

	private var a : NamedNodeMap;
	private var i : IntIterator;
}

class ElAttr {
	public inline function new(n:String, v:Ptr<String>):Void {
		name = n;
		val = v;
	}

	public inline function get():String return val.get();
	public inline function set(v : String):String return val.set( v );
	public inline function delete():Void val.delete();

	public var name : String;
	private var val : Ptr<String>;

	public static function fromAttr(p : Attr):ElAttr {
		return new ElAttr(p.name, Ptr.create( p.value ));
	}
}
