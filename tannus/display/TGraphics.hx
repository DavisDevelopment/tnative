package tannus.display;

import tannus.graphics.Color;
import tannus.graphics.GraphicsPath;

/**
  * Interface for the 'graphics' field of the Window class
  */
interface TGraphics {
	/**
	  * The dimensions of [this] Graphics
	  */
	var width(get, never) : Float;
	var height(get, never) : Float;
	/**
	  * Background Color
	  */
	var backgroundColor(get, set): Color;

	/**
	  * Method to create and return a new GraphicsPath instance
	  */
	function createPath() : GraphicsPath;

	/**
	  * Method to render a GraphicsPath
	  */
	function drawPath(path : GraphicsPath):Void;
}
