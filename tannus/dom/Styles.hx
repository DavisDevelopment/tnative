package tannus.dom;

import tannus.ds.Object;
import tannus.ds.Obj;
import tannus.io.Ptr;
import tannus.ds.EitherType;
import tannus.dom.Element;

import js.html.Element in JElement;
import js.html.CSSStyleDeclaration;
import js.Browser.window in win;

import Std.*;

@:forward
abstract Styles (CStyles) from CStyles to CStyles {
	/* Constructor Function */
	public inline function new(e : Element):Void {
		this = new CStyles( e );
	}

/* === Methods === */

	@:arrayAccess
	public inline function get(name : String):String {
		return this.get( name );
	}

	@:arrayAccess
	public inline function set(name:String, value:Dynamic):String {
		return this.set(name, value);
	}

	/**
	  * get a Pointer to the given Style
	  */
	public inline function ref(name : String):Ptr<String> {
		return new Ptr(this.get.bind( name ), this.set.bind(name, _));
	}

	@:to
	public inline function toObject():Object {
		return this.toObject();
	}

	@:op(A += B)
	public inline function write(o : Object):Void {
		this.write( o );
	}

	@:op(A |= B)
	public function pluck(keys : Array<String>):Object {
		var props:Object = {};
		for (key in keys) {
			props.set(key, get( key ));
		}
		return props;
	}
}

@:access( tannus.dom.Element.CElement )
@:access( tannus.dom.Element )
class CStyles {
	/* Constructor Function */
	public function new(e : Element):Void {
		element = e;
	}

/* === Instance Methods === */

	/**
	  * Get the value of the given property
	  */
	public function get(name : String):String {
		if (element.empty)
			return '';
		else {
			return (first().getPropertyValue( name ));
		}
	}

	/**
	  * Set the value of the given property
	  */
	public function set(name:String, value:Dynamic):String {
		for (css in all()) {
			css.setProperty(name, string(value));
		}
		return string( value );
	}

	/**
	  * Remove the given property
	  */
	public function remove(name : String):Void {
		for (css in all()) {
			css.removeProperty( name );
		}
	}

	/**
	  * Convert to an Object
	  */
	public function toObject():Object {
		var o:Object = {};
		var css = first();
		if (css != null) {
			for (i in 0...css.length) {
				var name = css.item( i );
				var value = css.getPropertyValue( name );
				o.set(name, value);
			}
		}
		return o;
	}

	/**
	  * Batch set properties
	  */
	public function write(o : Object):Void {
		for (css in all()) {
			for (name in o.keys) {
				css.setProperty(name, string(o[name]));
			}
		}
	}

	/**
	  * Get the styles for the first selected Element
	  */
	private function first():Null<CSSStyleDeclaration> {
		if (!element.empty) {
			return win.getComputedStyle( element.first );
		}
		else 
			return null;
	}

	/**
	  * Get the styles for all selected Elements
	  */
	private function all():Array<CSSStyleDeclaration> {
		return [for (e in element.els) e.style];
	}

/* === Instance Fields === */

	private var element : Element;
}
