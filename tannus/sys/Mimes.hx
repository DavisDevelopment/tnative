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
	private static var primitive:Object = {CompileTime.readJSON('internal/mimes.json', true);};

	/* Mime Data Registry, used internally by [this] Class */
	private static var types:Map<String, Array<String>>;

	/* Extension Registry */
	private static var extensions:Map<String, String>;

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
	  * Get an extension-name from a MIME type
	  */
	public static function getExtensionList(mime : String):Array<String> {
		if (types.exists( mime )) {
			return types.get( mime );
		}
		else {
			return new Array();
		}
	}

	/**
	  * Initialize [this] Class
	  */
	private static function __init():Void {
		types = new Map();
		extensions = new Map();

		var all:Array<String> = primitive.keys;
		for (ext in all) {
			var type:String = Std.string(primitive.get( ext ));
			extensions[ext] = type;
			if (types[type] == null) {
				types[type] = new Array();
			}
			types[type].push( ext );
		}

		initted = true;
	}
}
