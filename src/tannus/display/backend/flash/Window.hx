package tannus.display.backend.flash;

import tannus.display.backend.flash.*;
import tannus.display.TWindow;
import tannus.geom.Area;
import tannus.io.Signal;

import flash.Lib;
import flash.display.Sprite;
import flash.display.Graphics;
import flash.external.ExternalInterface;

@:allow(tannus.display.backend.flash.EventBinder)
class Window extends Sprite implements TWindow {
	/* Constructor Function */
	public function new():Void {
		super();
		instance = this;

		frameEvent = new Signal();
		resizeEvent = new Signal();

		var cur = flash.Lib.current;
		cur.addChild( this );
		stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;

		__init();
	}

/* === Instance Methods === */

	/**
	  * Initialize [this] Window
	  */
	private inline function __init():Void {
		sprite = this;

		var ebinder = new EventBinder(this);
		ebinder.bind();
		
		stage.addEventListener(flash.events.Event.EXIT_FRAME, function(event):Void {
			frameEvent.broadcast( null );
		});
	}

	private inline function js(code : String):Dynamic {
		return ExternalInterface.call('eval', code);
	}

/* === Instance Fields === */

	private var sprite:Sprite;

	public var resizeEvent : Signal<{then:Area, now:Area}>;
	public var frameEvent : Signal<Dynamic>;
	
/* === Computed Instance Fields === */

	/* Window Title */
	public var nc_title(get, set):String;
	private inline function get_nc_title():String {
		return (ExternalInterface.call('eval', 'window.document.title'));
	}
	private inline function set_nc_title(nt:String):String {
		return (ExternalInterface.call('eval', 'window.document.title = "$nt"'));
	}

	/* Window Dimensions */
	public var nc_size(get, set):Area;
	private function get_nc_size():Area {
		return new Area(sprite.width, sprite.height);
	}
	private function set_nc_size(a : Area):Area {
		sprite.width = a.width;
		sprite.height = a.height;

		return nc_size;
	}

/* === Class Fields === */

	//- The Window instance currently active
	public static var instance:Null<Window> = null;
}
