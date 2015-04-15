package tannus.display.backend.flash;

import tannus.display.backend.flash.*;
import tannus.display.TGraphics;
import tannus.geom.Point;
import tannus.geom.Rectangle;
import tannus.geom.Area;

import tannus.graphics.Color;
import tannus.graphics.GraphicsPath;

/**
  * Flash implementation of the TGraphics interface
  */
class TannusGraphics implements TGraphics {
	/* Constructor Function */
	public function new(owner : Window):Void {
		win = owner;

		//- default background color
		_bg = 0;
	}

/* === Instance Methods === */

	/**
	  * Creates and returns a new GraphicsPath
	  */
	public inline function createPath():GraphicsPath {
		return new GraphicsPath();
	}

	/**
	  * Renders a GraphicsPath onto [this] Graphics
	  */
	public function drawPath(path : GraphicsPath):Void {
		null;
	}


/* === Computed Instance Fields === */

	/**
	  * The Background Color of the Window
	  -----
	  * This is a computed field, because on some targets,
	  * actions will need to be performed when this value changes
	  */
	public var backgroundColor(get, set):Color;
	private function get_backgroundColor():Color {
		return (_bg);
	}
	private function set_backgroundColor(nbg : Color):Color {
		return (_bg = nbg);
	}

/* === Instance Fields === */

	private var win : Window;
	private var _bg : Color;
}
