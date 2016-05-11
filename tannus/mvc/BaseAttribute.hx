package tannus.mvc;

import tannus.io.Signal;
import tannus.ds.Delta;
import tannus.utils.Error;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;
using tannus.macro.MacroTools;

class BaseAttribute<T> {
	/* Constructor Function */
	public function new():Void {
		change = new Signal();
		keychange = new Signal();
		keys = new Array();
	}

/* === Instance Methods === */

	/**
	  * Get the value of [this] Attribute
	  */
	public function get():T N.report();

	/**
	  * Assign the value of [this] Attribute
	  */
	public function set(value : T):T N.report();

	/**
	  * Actually delete the stored value
	  */
	public function delete():Bool return false;

	/**
	  * Dispose of [this] Attribute object, but not the data stored by it
	  */
	public function dispose():Void {
		null;
	}

	/**
	  * Check for the existence of [this] Attribute
	  */
	public function exists():Bool return false;

	/**
	  * "allocate" the given key
	  */
	public function allockey(key : String):Void {
		if (!keys.has( key )) {
			keys.push( key );
		}
	}

	/**
	  * free up (or "deallocate") a key
	  */
	public function deallockey(key : String):Bool {
		return keys.remove( key );
	}

	/**
	  * Method which returns the default value for [this] Attribute
	  */
	public dynamic function defaultValue():T N.report();

/* === Computed Instance Fields === */

	/* the value of [this] Attribute */
	public var value(get, set):T;
	private function get_value():T return get();
	private function set_value(v : T):T return set( v );

	public var v(get, set):T;
	private function get_v():T return get();
	private function set_v(v : T):T return set( v );

/* === Instance Fields === */

	/* the name of [this] Attribute */
	public var name : String;

	/* any/all keys reserved by [this] Attribute */
	public var keys : Array<String>;
	
	/* the Signal fired when a change occurs in [this] Attribute */
	public var change : Signal<Delta<T>>;
	public var keychange : Signal<Delta<T>>;

	private static inline var N:String = 'Not implemented';
}
