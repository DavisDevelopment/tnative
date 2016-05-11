package tannus.mvc;

import tannus.io.Signal;
import tannus.ds.Delta;

import tannus.mvc.Model;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;
using tannus.macro.MacroTools;

class Attribute<T> extends BaseAttribute<T> {
	/* Constructor Function */
	public function new(m:Model, n:String):Void {
		super();

		model = m;
		name = n;

		__listen();
	}

/* === Instance Methods === */

	/**
	  * Unbind [this] Attribute from its Model
	  */
	public function unbind():Void {
		model.unwatch( onchange );
	}

	public function rebind(m : Model):Void {
		unbind();
		
		model = m;
		__listen();
	}

	/**
	  * get the value of [this] Attribute
	  */
	public override function get():T {
		if (!exists()) {
			return set(defaultValue());
		}
		else return model.get( name );
	}

	/**
	  * set the value of [this] Attribute
	  */
	public override function set(value : T):T {
		return model.set(name, value);
	}

	/* get the value stored under the given key */
	public function kg<T>(key : String):T return untyped model.get( key );
	public function ks<T>(key:String, value:T):T return untyped model.set(key, value);

	/**
	  * delete [this] Attribute's underlying data
	  */
	public override function delete():Bool {
		return model.remove( name );
	}

	/**
	  * delete [this] Attribute object instance
	  */
	override public function dispose():Void {
		for (key in keys) {
			deallockey( key );
		}
		model.am.removeAttribute( this );
	}

	/**
	  * check whether [this] Attribute exists
	  */
	public override function exists():Bool {
		return model.exists( name );
	}

	/**
	  * allocate a key
	  */
	override public function allockey(key : String):Void {
		model.am.allockey(this, key);
		super.allockey( key );
	}

	/**
	  * deallocate a key
	  */
	override public function deallockey(key : String):Bool {
		var r = super.deallockey( key );
		model.removeAttribute( key );
		return r;
	}

	/**
	  * handle change-events from [model]
	  */
	private function onchange(mc : Model.ModelChange<T>):Void {
		if (mc.name == name) {
			change.call( mc.value );
		}
		else if (keys.has( mc.name )) {
			keychange.call( mc.value );
		}
		else {
			return ;
		}
	}

	/**
	  * bind events
	  */
	private inline function __listen():Void {
		model.watch( onchange );
	}

/* === Instance Fields === */

	/* the Model from which [this] Attribute is obtained */
	public var model : Model;
}
