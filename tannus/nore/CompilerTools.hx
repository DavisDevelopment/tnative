package tannus.nore;

import tannus.ds.Object;
import tannus.internal.TypeTools in Tt;

using Lambda;
using tannus.ds.ArrayTools;
using tannus.nore.ValueTools;
using StringTools;
using tannus.ds.StringUtils;

@:access( tannus.nore.Compiler )
class CompilerTools {
	/* Constructor Function */
	public function new(owner : Compiler):Void {
		c = owner;
	}

/* === Instance Methods === */

	/**
	  * determine whether [o] has field [name]
	  */
	public function has(o:Object, name:String):Bool {
		return o.exists( name );
	}

	/**
	  * Get the value of field [name] of [o]
	  */
	public function get(o:Object, name:String):Dynamic {
		return o[name];
	}

	/**
	  * Check that [o] is of type [type]
	  */
	public function checkType(o:Object, type:String, loose:Bool=false):Bool {
		if ( !loose ) {
			return (Tt.typename(o) == type);
		}
		else {
			var tc:Class<Dynamic> = Type.resolveClass( type );
			return Std.is(o, tc);
		}
	}

	/**
	  * Check that [o]'s type-name ends with [type]
	  */
	public function checkShortType(o:Object, type:String):Bool {
		var className:String = Tt.typename(o).split('.').last();
		return (className == type);
	}

	/**
	  * Perform a helper-check
	  */
	public function helper_check(o:Object, name:String, vargs:Array<Value>):Bool {
		var args:Array<Dynamic> = [for (v in vargs) v.haxeValue(this, o).get()];
		if (c.helpers.exists( name )) {
			var help = c.helpers.get( name );
			return help(o, args);
		}
		else {
			if (has(o, name)) {
				var v:Object = get(o, name);
				if (v.istype(Bool)) {
					return cast v;
				}
				else if (Reflect.isFunction(v)) {
					return (Reflect.callMethod(o, get(o, name), args) == true);
				}
				else {
					return false;
				}
			}
			else {
				return false;
			}
		}
	}

/* === Instance Fields === */

	private var c : Compiler;
}
