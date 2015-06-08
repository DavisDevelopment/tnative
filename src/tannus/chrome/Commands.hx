package tannus.chrome;

import tannus.ds.Maybe;
import tannus.ds.Object;

class Commands {
	/**
	  * Listen for Commands
	  */
	public static inline function onCommandRaw(cb : String->Void):Void {
		lib.onCommand.addListener( cb );
	}

	/**
	  * Obtain Array of Commands
	  */
	public static inline function getAll(cb : Array<Command>->Void):Void {
		lib.getAll( cb );
	}

	/**
	  * Listen for Commands, more concisely
	  */
	public static inline function onCommand(cb : Command->Void):Void {
		onCommandRaw(function( name ) {
			getAll(function( comms ) {
				for (c in comms) {
					if (c.name == name) {
						cb( c );
						break;
					}
				}
			});
		});
	}

	/**
	  * Listen for a Specific Command
	  */
	public static inline function onCommandByName(name:String, cb:Void->Void) {
		onCommandRaw(function( cmdName ) {
			if (cmdName == name) {
				cb();
			}
		});
	}
	
	/**
	  * Object used internally by [this] Class
	  */
	public static var lib(get, never):Dynamic;
	private static inline function get_lib():Dynamic {
		return (untyped __js__('chrome.commands'));
	}
}

private typedef Command = {
	var name : Null<String>;
	var description : Null<String>;
	var shortcut : Null<String>;
};
