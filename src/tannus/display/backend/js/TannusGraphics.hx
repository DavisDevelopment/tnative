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
		pr = new PathRenderer( this );
	}

/* === Instance Methods === */

	/**
	  * Create and return a new GraphicsPath
	  */
	public inline function createPath():GraphicsPath {
		var gp = new GraphicsPath();
		gp.graphics = this;
		return gp;
	}

	/**
	  * Render a GraphicsPath onto [this] Graphics
	  */
	public function drawPath(path : GraphicsPath):Void {
		pr.draw( path );
	}


/* === Instance Fields === */

	public var win : Window;
	private var _bg : Color;

	//- The PathRenderer for [this] Graphics
	private var pr : PathRenderer;

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

	/**
	  * The 'width' of [this] Graphics
	  */
	public var width(get, never) : Float;
	private inline function get_width():Float {
		return (ctx.canvas.width);
	}

	/**
	  * The 'height' of [this] Graphics
	  */
	public var height(get, never) : Float;
	private inline function get_height():Float {
		return (ctx.canvas.height);
	}
}
