package tannus.html;

import tannus.io.Ptr;
import tannus.ds.Maybe;
import tannus.ds.Object;
import tannus.ds.TwoTuple;

import tannus.html.Element;

abstract ElStyles (Styler) {
	/* Constructor Function */
	public inline function new(af : Styler):Void {
		this = af;
	}

	/**
	  * Retrieve the given css-property value
	  */
	@:arrayAccess
	public inline function get(key : String):String {
		return this([key]);
	}

	/**
	  * Reassigns a css-property value
	  */
	@:arrayAccess
	public inline function set(key:String, val:Dynamic):String {
		this([key, Std.string(val)]);
		return this([key]);
	}

	/**
	  * Copy [keys] from [other] onto [this]
	  */
	public inline function copy(other:ElStyles, keys:Array<String>):Void {
		for (k in keys) set(k, other[k]);
	}

	/**
	  * Obtain a pointer to the value of a particular css-property
	  */
	public inline function reference(key : String):Ptr<String> {
		var s:ElStyles = new ElStyles(this);

		return Ptr.create(s[key]);
	}

	/**
	  * Get an Object of css-properties from an Array of keys
	  */
	public function gets(keys : Array<String>):Object {
		var o:Object = {};
		for (k in keys)
			o[k] = get(k);
		return o;
	}

	/**
	  * Write an Object onto [this] Style Set
	  */
	@:op(A += B)
	public function writeObject(o : Object):Void {
		for (p in o) {
			set(p.name, Std.string(p.value));
		}
	}
}

private typedef Styler = Array<String>->String;
