package tannus.display.backend.flash;

import tannus.display.backend.flash.*;
import flash.display.Stage;
import tannus.io.Signal;
import tannus.io.Ptr;

import tannus.geom.Area;
import tannus.geom.Point;

import tannus.events.MouseEvent;
import tannus.events.EventMod;
import tannus.events.EventCreator;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.display.Sprite;

/**
  * Class which binds all relevant Event Listeners to the Window
  */
class EventBinder implements EventCreator {
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

		bindMouseEvents();
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

	/**
	  * Attaches all MouseEvent Listeners to the Window
	  */
	private function bindMouseEvents():Void {
		var fm = FMouseEvent;
		var listenFor:Array<String> = [fm.CLICK, fm.MOUSE_DOWN, fm.MOUSE_UP, fm.MOUSE_MOVE];

		for (t in listenFor) {
			stage.addEventListener(t, function(fme : FMouseEvent):Void {
				var event:MouseEvent = createTannusMouseEvent( fme );

				win.mouseEvent.broadcast( event );
			});
		}
	}

	/**
	  * Create a Tannus MouseEvent from a Flash MouseEvent
	  */
	private function createTannusMouseEvent(e : FMouseEvent):MouseEvent {
		var mods:Array<EventMod> = new Array();

		if (e.altKey) mods.push( Alt );
		if (e.ctrlKey) mods.push( Control );
		if (e.shiftKey) mods.push( Shift );

		var type:String = (e.type.toLowerCase());
		var pos:Point = new Point(e.stageX, e.stageY);
		var mev:MouseEvent = new MouseEvent(type, pos, e.delta, mods);

		mev.onDefaultPrevented.once(function(v) e.preventDefault());
		mev.onPropogationStopped.once(function(v) e.stopPropagation());

		return mev;
	}

/* === Computed Fields === */

	private var stage(get, never):Stage;
	private inline function get_stage():Stage {
		return (win.stage);
	}


/* === Instance Fields === */

	private var win:Window;
}

/* === Type Aliases === */
private typedef FMouseEvent = flash.events.MouseEvent;
