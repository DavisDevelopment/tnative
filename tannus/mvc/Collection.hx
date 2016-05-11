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
  * A Collection of Attributes, which may or may not be from the same Model, or even attached to a Model at all
  */
class Collection {
	/* Constructor Function */
	public function new():Void {
		a = new Array();
	}

/* === Instance Methods === */

	/**
	  * add the given Attribute to [this] Collection
	  */
	public function addAttribute<T>(attr : Attr<T>):Void {
		validate( attr );
		a.push( attr );
	}

	/**
	  * remove the given Attribute from [this] Collection
	  */
	public function removeAttribute<T>(attr : Attr<T>):Bool {
		return a.remove( attr );
	}

	/**
	  * get an Attribute by name
	  */
	public function getAttribute<T:Attr<Dynamic>>(n : String):Null<T> {
		for (x in a) {
			if (x.name == n) {
				return untyped x;
			}
		}
		return null;
	}

	/**
	  * validate the given Attribute, primary to ensure that
	  * no keys are being used by it that are already reserved
	  */
	private function validate<T>(attr : Attr<T>):Void {
		var vkeys:Array<String> = ([attr.name].concat( attr.keys ));
		
		for (x in a) {
			if (x != attr && x.name == attr.name) {
				'AttributeError: There is already an Attribute named "${x.name}" attached to [this] Collection'.report();
			}
			else {
				// overlap between the two sets of secondary keys
				var skol = x.keys.union( attr.keys );
				
				/* if the two attributes have any keys in common */
				if (skol.length > 0) {
					// validation failed
					'AttributeError: Attribute "${attr.name}" has the following keys in common with another Attribute: (${skol.join(', ')})'.report();
				}
				else {
					// the overlap (if any) between an Array of *all* keys used by [x] and *all* keys used by [attr]
					var gol = ([x.name].concat(x.keys)).union([attr.name].concat(attr.keys));

					/* if [gol] is not empty */
					if (!gol.empty()) {
						'AttributeError: Attribute "${attr.name}" utilizes keys already in use by another Attribute'.report();
					}
				}
			}
		}
	}

/* === Instance Fields === */

	private var a : Array<Attr<Dynamic>>;
}
