package tannus.display.backend.flash;

import tannus.display.backend.flash.*;
import flash.display.Stage;
import tannus.io.Signal;
import tannus.io.Ptr;
import tannus.geom.Area;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.display.Sprite;

/**
  * Class which binds all relevant Event Listeners to the Window
  */
class EventBinder {
	/* Constructor Function */
	public function new(owner : Window):Void {
		win = owner;
	}

/* === Instance Methods === */

	/**
	  * Primary method of this Class, which performs all of the bindings
	  */
	public function bind():Void {
		
		bindWindowEvents();
	}

	/**
	  * Attaches all WindowEvent Listeners to the Window
	  */
	private function bindWindowEvents():Void {
		/* == RESIZE Event == */
		var la:Area = win.nc_size;
		stage.addEventListener(Event.RESIZE, function(e : Event):Void {
			win.resizeEvent.call({
				'then' : la,
				'now'  : win.nc_size
			});
			
			win.__prepareCanvas();
			la = win.nc_size;
		});
	}

/* === Computed Fields === */

	private var stage(get, never):Stage;
	private inline function get_stage():Stage {
		return (win.stage);
	}


/* === Instance Fields === */

	private var win:Window;
}
