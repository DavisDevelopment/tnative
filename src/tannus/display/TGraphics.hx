package tannus.display;

import tannus.graphics.Color;

/**
  * Interface for the 'graphics' field of the Window class
  */
interface TGraphics {
	/**
	  * Background Color
	  */
	var backgroundColor(get, set): Color;

	/**
	  * Method to create and return a new GraphicsPath instance
	  */
}
