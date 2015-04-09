package tannus.display;

import tannus.geom.Area;
import tannus.geom.Rectangle;
import tannus.io.Signal;

/**
  * Generic Window interface to allow autocompletion
  */
interface TWindow {

	/* Window Title */
	var nc_title(get, set):String;

	/* Window Size */
	var nc_size(get, set):Area;

	/* Signal Fired When Window is Resized */
	var resizeEvent : Signal<{then:Area, now:Area}>;

	/* Signal Fired Every Frame */
	var frameEvent : Signal<Dynamic>;
}
