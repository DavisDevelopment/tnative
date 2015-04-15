package tannus.display.backend.js;

import tannus.display.backend.js.*;
import tannus.geom.Area;
import tannus.geom.Point;

import tannus.io.Signal;
import tannus.io.Ptr;

/**
  * Class to bind all relevant event-listeners to the Window
  */
class EventBinder {
	/* Constructor Function */
	public function new(owner : Window):Void {
		win = owner;
	}

/* === Instance Methods === */

	/**
	  * Primary method, which invokes all the others
	  */
	public function bind():Void {

		bindWindowEvents();
	}

	/**
	  * Attach listeners for all window-related events
	  */
	private function bindWindowEvents():Void {
		/* === RESIZE Event === */
		var la:Area = win.nc_size;
		w.addEventListener('resize', function(event) {
			win.makeFullScreen(win.canvas);
			win.ctx = win.canvas.getContext('2d');

			win.resizeEvent.call({
				'then' : la,
				'now'  : win.nc_size
			});

			la = win.nc_size;
		});
	}

/* === Computed Instance Fields === */

	/* Reference to the Browser Document */
	private var d(get, never):js.html.Document;
	private inline function get_d() return js.Browser.document;
	
	/* Reference to [d] as Dynamic */
	private var doc(get, never):Dynamic;
	private inline function get_doc() return d;

	/* Reference to the Browser window */
	private var w(get, never):js.html.Window;
	private inline function get_w() return js.Browser.window;

/* === Instance Fields === */

	private var win : Window;
}
