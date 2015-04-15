package tannus.display.backend.js;

import tannus.display.backend.js.*;
import tannus.display.TGraphics;

import tannus.graphics.Color;
import tannus.graphics.GraphicsPath;

import tannus.io.Signal;
import tannus.io.Ptr;

import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;

class TannusGraphics implements TGraphics {
	/* Constructor Function */
	public function new(owner : Window):Void {
		win = owner;

		_bg = 0;
	}

/* === Instance Methods === */

	/**
	  * Create and return a new GraphicsPath
	  */
	public inline function createPath():GraphicsPath {
		return new GraphicsPath();
	}

	/**
	  * Render a GraphicsPath onto [this] Graphics
	  */
	public function drawPath(path : GraphicsPath):Void {
		null;
	}


/* === Instance Fields === */

	private var win : Window;
	private var _bg : Color;

	/**
	  * Background Color of [this] Graphics
	  */
	public var backgroundColor(get, set) : Color;
	private inline function get_backgroundColor():Color {
		return _bg;
	}
	private inline function set_backgroundColor(nc : Color):Color {
		return (_bg = nc);
	}

	/**
	  * The rendering context in use by the Window [this] Graphics is operating on
	  */
	private var ctx(get, never) : CanvasRenderingContext2D;
	private inline function get_ctx():CanvasRenderingContext2D {
		return win.ctx;
	}
}
