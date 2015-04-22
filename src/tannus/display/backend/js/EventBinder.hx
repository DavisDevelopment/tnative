package tannus.display.backend.js;

import tannus.display.backend.js.*;
import tannus.geom.Area;
import tannus.geom.Point;

import tannus.events.MouseEvent;
import tannus.events.EventCreator;
import tannus.events.EventMod;

import tannus.io.Signal;
import tannus.io.Ptr;

/**
  * Class to bind all relevant event-listeners to the Window
  */
class EventBinder implements EventCreator {
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
		bindMouseEvents();
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

	/**
	  * Attach listeners for all mouse-events
	  */
	private function bindMouseEvents():Void {
		var listenFor:Array<String> = ['mousedown', 'mouseup', 'mousemove', 'click'];
		
		for (t in listenFor) {
			w.addEventListener(t, function(event : js.html.MouseEvent):Void {
				var me:MouseEvent = createTannusEvent(event);

				win.mouseEvent.broadcast( me );
			});
		}
	}

	/**
	  * Create a Tannus Event from an HTML5 Event
	  */
	private function createTannusEvent(e : js.html.MouseEvent):MouseEvent {
		var mods:Array<EventMod> = new Array();
		
		if (e.altKey) mods.push( Alt );
		if (e.shiftKey) mods.push( Shift );
		if (e.ctrlKey) mods.push( Control );
		if (e.metaKey) mods.push( Meta );

		var button:Int = e.button;
		var pos:Point = new Point(e.clientX, e.clientY);

		var mev:MouseEvent = new MouseEvent(e.type, pos, button, mods);
		mev.onDefaultPrevented.once(function(v) e.preventDefault());
		mev.onPropogationStopped.once(function(v) e.stopPropagation());

		return mev;
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
