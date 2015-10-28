package tannus.display;

import tannus.geom.Area;
import tannus.geom.Rectangle;
import tannus.io.Signal;

import tannus.events.*;

/**
  * Generic Window interface to allow autocompletion
  */
interface TWindow {

	/* Window Title */
	var nc_title(get, set):String;

	/* Window Size */
	var nc_size(get, set):Area;
	
	/* TGraphics instance in use by [this] TWindow */
	var nc_graphics : TGraphics;

	/* Signal Fired When Window is Resized */
	var resizeEvent : Signal<{then:Area, now:Area}>;

	/* Signal Fired Every Frame */
	var frameEvent : Signal<Dynamic>;

	/* Signal Fired Upon Receipt of a Mouse Event */
	var mouseEvent : Signal<MouseEvent>;

	/* Show Alert Box */
	function alert(message : String):Void;

	/* Prompt User for Text Input */
	function prompt(question : String):String;
}
