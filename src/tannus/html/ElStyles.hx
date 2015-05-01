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
	  * Obtain a pointer to the value of a particular css-property
	  */
	public inline function reference(key : String):Ptr<String> {
		var s:ElStyles = new ElStyles(this);

		return Ptr.create(s[key]);
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
