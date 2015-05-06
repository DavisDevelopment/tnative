package tannus.graphics;

import tannus.graphics.*;

class PathStyle {
	/* Constructor Function */
	public function new():Void {
		lineStyle = new LineStyle();

		fillBrush = '#000';

		reset();
	}

/* === Instance Methods === */

	/**
	  * Restore [this] to it's default state
	  */
	public inline function reset():Void {
		lineStyle.reset();
	}

	/**
	  * Create and return a clone of [this]
	  */
	public inline function clone():PathStyle {
		var c = new PathStyle();
		c.lineStyle = lineStyle.clone();

		return c;
	}

/* === Instance Fields === */

	//- line-related styles
	public var lineStyle:LineStyle;

	public var fillBrush : GraphicsBrush;
}
