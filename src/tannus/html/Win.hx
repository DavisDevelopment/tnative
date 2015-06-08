package tannus.html;

import js.Browser.window in win;
import js.html.Window in CWin;

import tannus.ds.Object;
import tannus.ds.Maybe;
import tannus.ds.Range;
import tannus.io.Ptr;
import tannus.io.Signal;

import tannus.geom.Point;
import tannus.geom.Rectangle;
import tannus.geom.Angle;
import tannus.geom.Area;
import tannus.geom.Velocity;

using StringTools;
using Lambda;

@:forward
abstract Win (CWin) from CWin to CWin {
	/* Constructor Function */
	public inline function new(?w:CWin):Void {
		this = ((w != null) ? w : win);
	}

/* === Instance Fields === */

	/**
	  * The current viewport
	  */
	public var viewport(get, never):Rectangle;
	private inline function get_viewport():Rectangle {
		return new Rectangle(this.scrollX, this.scrollY, this.innerWidth, this.innerHeight);
	}

/* === Static Fields === */

	/**
	  * The current Window
	  */
	public static var current(get, never):Win;
	private static inline function get_current() return new Win();
}
