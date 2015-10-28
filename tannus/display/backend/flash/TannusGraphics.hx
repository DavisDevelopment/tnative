package tannus.display.backend.flash;

import tannus.display.backend.flash.*;
import tannus.display.backend.flash.PathRenderer;
import tannus.display.TGraphics;
import tannus.geom.Point;
import tannus.geom.Rectangle;
import tannus.geom.Area;

import tannus.graphics.Color;
import tannus.graphics.GraphicsPath;

/**
  * Flash implementation of the TGraphics interface
  */
@:allow(tannus.display.backend.flash.PathRenderer)
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
		var gp = new GraphicsPath();
		gp.graphics = this;
		return gp;
	}

	/**
	  * Renders a GraphicsPath onto [this] Graphics
	  */
	public function drawPath(path : GraphicsPath):Void {
		var pr = new PathRenderer( this );
		pr.draw( path );
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

	/**
	  * The 'width' of [this] Graphics
	  */
	public var width(get, never):Float;
	private inline function get_width():Float {
		return (win.width);
	}

	/**
	  * The 'height' of [this] Graphics
	  */
	public var height(get, never):Float;
	private inline function get_height():Float {
		return (win.height);
	}

/* === Instance Fields === */

	private var win : Window;
	private var _bg : Color;
}
