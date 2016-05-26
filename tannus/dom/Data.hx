package tannus.dom;

import tannus.dom.Element;
import tannus.dom.Element.CElement;
import tannus.dom.Element.NodeData;
import tannus.ds.Obj;
import tannus.io.Ptr;

import js.html.Element in JElement;

@:forward
abstract Data (CData) from CData to CData {
	/* Constructor Function */
	public inline function new(e : Element):Void {
		this = new CData( e );
	}

/* === Methods === */

	@:arrayAccess
	public inline function get<T>(k : String):Null<T> return this.get( k );
	@:arrayAccess
	public inline function set<T>(k:String, v:T):Void this.set(k, v);
}

class CData {
	/* Constructor Function */
	public function new(e : Element):Void {
		el = e;
	}

/* === Instance Methods === */

	/**
	  * Get the value of a property
	  */
	public function get<T>(name : String):Null<T> {
		if (!el.empty) {
			return nd(el.first).pub.get( name );
		}
		else {
			return null;
		}
	}

	/**
	  * Set the value of a property
	  */
	public function set<T>(name:String, value:T):Void {
		for (e in el.els) {
			nd(e).pub.set(name, value);
		}
	}

	/**
	  * Check for existence of a property
	  */
	public function exists(name : String):Bool {
		if (!el.empty) {
			return (nd(el.first).pub.exists( name ));
		}
		else {
			return false;
		}
	}

	/**
	  * Iterate over all keys in [this] data
	  */
	public function keys():Array<String> {
		if (!el.empty) {
			return nd(el.first).pub.keys();
		}
		else {
			return new Array();
		}
	}

	/**
	  * Do the stuff
	  */
	public function ref<T>(name : String):Ptr<T> {
		return nd(el.first).pub.field( name );
	}

	/**
	  * Get the NodeData associated with the given JElement
	  */
	private inline function nd(e : JElement):NodeData {
		return (untyped Reflect.getProperty(e, DATAKEY));
	}

/* === Instance Fields === */

	private var el : Element;

/* === Static Fields === */

	private static inline var DATAKEY:String = '__tandata';
}
