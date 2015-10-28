package tannus.display.backend.java;

import tannus.display.backend.java.*;
import tannus.display.backend.java.PathRenderer;
import tannus.display.TGraphics;

import tannus.graphics.Color;
import tannus.graphics.GraphicsPath;

import tannus.io.Signal;
import tannus.io.Ptr;

class TannusGraphics implements TGraphics {
	/* Constructor Function */
	public function new(owner : Window):Void {
		win = owner;

		backgroundColor = 0;
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

/* === Instance Fields === */

	//- Reference to the Window object [this] Graphics operates on
	public var win : Window;

	//- internal variable to store the current background color
	private var _bg : Color;

	/**
	  * The background color of [this] Graphics
	  */
	public var backgroundColor(get, set) : Color;
	private inline function get_backgroundColor():Color {
		//- return [_bg], because backgroundColor shouldn't be changable without using this interface
		return _bg;
	}
	private inline function set_backgroundColor(nc : Color):Color {
		win.setBackground( nc );
		return (_bg = nc);
	}

	/**
	  * The 'width' of [this] Graphics
	  */
	public var width(get, never):Float;
	private inline function get_width():Float {
		return (win.nc_size.width);
	}

	/**
	  * The 'height' of [this] Graphics
	  */
	public var height(get, never):Float;
	private inline function get_height():Float {
		return (win.nc_size.height);
	}
}
