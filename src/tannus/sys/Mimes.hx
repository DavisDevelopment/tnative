package tannus.sys;

import tannus.internal.CompileTime;
import tannus.ds.Object;
import Std.*;

using Lambda;
using StringTools;
@:expose
class Mimes {

/* === Class Fields === */

	/* Primitive Mime Data, Loaded from a JSON File */
	private static var primitive:Object = {CompileTime.readJSON('tannus/src/tannus/sys/mimes.json');};

	/* Mime Data Registry, used internally by [this] Class */
	private static var types:Object;

	/* Extension Registry */
	private static var extensions:Object;

	/* Whether [this] Class has been initialized */
	private static var initted:Bool = false;

/* === Class Methods === */

	/**
	  * Get a MIME Type, from an extension-name
	  */
	public static function getMimeType(ext : String):Null<String> {
		if (!initted)
			__init();

		if (ext.startsWith('.'))
			ext = ext.substring( 1 );

		return (extensions[ext]);
	}

	/**
	  * Initialize [this] Class
	  */
	private static function __init():Void {
		types = {};
		extensions = {};

		var all:Array<String> = primitive.keys;
		for (t in all) {
			var exten:Array<Dynamic> = cast(primitive[t].or([]), Array<Dynamic>);
			
			types[t] = exten.map( string );

			for (ext in exten.map(string)) {
				extensions[ext] = t;
			}
		}

		initted = true;
	}
}
