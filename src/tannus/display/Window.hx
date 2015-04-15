package tannus.display;

import tannus.display.TWindow;

import tannus.geom.Area;

@:forward
abstract Window (TWindow) {
	public inline function new():Void {
		#if (js && !node)

			this = new tannus.display.backend.js.Window();

		#elseif (flash || as3)

			this = new tannus.display.backend.flash.Window();

		#elseif java

			this = new tannus.display.backend.java.Window();

		#else
			throw 'Cannot create Window on the current target';
		#end
	}

/* === Alias 'nc_' (Non-Conflicting) Fields to Their Intended Names === */

	/**
	  * Window Title
	  */
	public var title(get, set):String;
	private inline function get_title() return (this.nc_title);
	private inline function set_title(nt:String) return (this.nc_title = nt);

	/**
	  * Window Size
	  */
	public var size(get, set):Area;
	private inline function get_size() return (this.nc_size);
	private inline function set_size(ns:Area) return (this.nc_size = ns);

	/**
	  * Window Graphics
	  */
	public var graphics(get, never):TGraphics;
	private inline function get_graphics() return (this.nc_graphics);
}
