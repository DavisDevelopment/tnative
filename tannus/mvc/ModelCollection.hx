package tannus.mvc;

import tannus.ds.Dict;
import tannus.utils.Error;

import tannus.mvc.BaseAttribute in Attr;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;
using tannus.macro.MacroTools;

/**
  * A specialized Collection used by Models for keeping track of bound Attributes
  */
class ModelCollection extends Collection {
	/* Constructor Function */
	public function new(m : Model):Void {
		super();

		model = m;
	}

/* === Instance Methods === */

	/**
	  * Attempt to allocate a key
	  */
	public function allockey(allocer:Attr<Dynamic>, key:String):Void {
		for (atr in a) {
			if (atr != allocer && (atr.name == key || atr.keys.has( key ))) {
				throw new Error('AttributeError: Attempted to allocate key "$key" (already allocated by the "${atr.name}" Attribute)');
			}
		}
	}

/* === Instance Fields === */

	public var model : Model;
}
