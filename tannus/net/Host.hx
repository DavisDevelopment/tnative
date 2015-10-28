package tannus.net;

abstract Host (String) from String {
	/* Constructor Function */
	public inline function new(s : String):Void {
		this = s;
	}

/* === Instance Fields === */

/* === Type Casting === */

#if !js
	/**
	  * Converts to a native Host object
	  */
	@:to
	public inline function toNativeHost():sys.net.Host {
		return new sys.net.Host(this);
	}
#end
}
