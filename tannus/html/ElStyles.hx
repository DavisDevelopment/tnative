package tannus.html;

import tannus.io.Ptr;
import tannus.ds.*;

import tannus.css.Value;
import tannus.css.vals.*;

import tannus.html.Element;

import Std.*;

using Lambda;
using tannus.ds.ArrayTools;
using StringTools;
using tannus.ds.StringUtils;
using tannus.ds.MapTools;
using tannus.css.vals.ValueTools;
using Reflect;

@:forward
abstract ElStyles (CElStyles) from CElStyles to CElStyles {
	/* Constructor Function */
	private inline function new(e : Element):Void {
		this = new CElStyles( e );
	}

/* === Operator Methods === */

	@:arrayAccess
	public inline function get(name : String):Maybe<String> return this.get( name );
	@:arrayAccess
	public inline function set(name:String, value:String):String return this.set(name, value);

/* === Casting Methods === */

	@:from
	public static inline function fromElement(e : Element):ElStyles {
		return e.style;
	}

	/**
	  * factory method for ElStyles
	  */
	public static function create(elem : Element):ElStyles {
		var key:String = '__tannus_styles';
		var css:Null<ElStyles> = elem.getProperty( key );
		if (css == null) {
			elem.setProperty(key, css = new ElStyles( elem ));
		}
		return css;
	}
}

class CElStyles {
	/* Constructor Function */
	public function new(e : Element):Void {
		elem = e;
	}

/* === Instance Methods === */

	/**
	  * Get the value of a singular css-property
	  */
	public function get(name : String):Maybe<String> {
		return elem.css( name );
	}

	/**
	  * Set the value of a css-property
	  */
	public function set(name:String, value:String):String {
		elem.css(name, value);
		return get( name );
	}

	/**
	  * Check whether the given css-property even exists
	  */
	public inline function exists(name : String):Bool {
		return get( name ).toBoolean();
	}

	/**
	  * Obtain a Pointer to the given css-property
	  */
	public inline function reference(name : String):Ptr<String> {
		return new Ptr(cast get.bind( name ), set.bind(name, _));
	}

	/**
	  * parse and return the values of the given css-property
	  */
	public function values(name : String):Array<Value> {
		var s = get( name );
		if (s != null) {
			return Lexer.parseString( s );
		}
		else return new Array();
	}

	/**
	  * grab the values of several properties
	  */
	public function pluck(names : Array<String>):Object {
		var o:Object = new Object({});
		for (name in names) {
			o[name] = get( name );
		}
		return o;
	}
	public inline function gets(names : Array<String>):Object return pluck( names );

	/**
	  * apply a Map<String, Dynamic> of properties to [this]
	  */
	public function applyMap(map : Map<String, Dynamic>):Void {
		for (name in map.keys()) {
			set(name, string(map.get( name )));
		}
	}

	/**
	  * apply a Dict<String, Dynamic> of properties to [this]
	  */
	@:access( tannus.ds.dict.StringDict )
	public inline function applyDict(map : Dict<String, Dynamic>):Void {
		applyMap(cast(map, tannus.ds.dict.StringDict<Dynamic>).m);
	}

	/**
	  * apply an Object of properties to [this]
	  */
	public function applyObject(o : Object):Void {
		for (name in o.keys) {
			set(name, string(o.get( name )));
		}
	}
	public inline function writeObject(o : Object):Void applyObject( o );
	public inline function write(o : Object):Void writeObject( o );

	/**
	  * Copy the given properties from [other] to [this]
	  */
	public function copy(keys:Array<String>, other:ElStyles):Void {
		applyObject(other.pluck( keys ));
	}

/* === Instance Fields === */

	private var elem : Element;
}
