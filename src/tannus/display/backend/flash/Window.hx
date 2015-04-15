package tannus.display.backend.flash;

import tannus.display.backend.flash.*;
import tannus.display.TWindow;
import tannus.geom.Area;
import tannus.io.Signal;

import flash.Lib;
import flash.display.Sprite;
import flash.display.Shape;
import flash.display.Graphics;
import flash.external.ExternalInterface;

import haxe.Timer;

@:allow(tannus.display.backend.flash.EventBinder)
class Window extends Sprite implements TWindow {
	/* Constructor Function */
	public function new():Void {
		super();
		instance = this;

		frameEvent = new Signal();
		resizeEvent = new Signal();
		nc_graphics = new TannusGraphics(this);

		var cur = flash.Lib.current;
		cur.addChild( this );
		stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;

		__prepareCanvas();
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
		
		//stage.addEventListener(flash.events.Event.ENTER_FRAME, function(event):Void {
			//__perFrameInternal();

			//frameEvent.broadcast( null );
		//});
		var t:Timer = new Timer( 30 );
		t.run = function() {
			__perFrameInternal();

			frameEvent.broadcast( nc_graphics );
		};

		__perFrameInternal();
	}

	/**
	  * Nitty Gritty internals that need to be run per-frame
	  */
	private inline function __perFrameInternal():Void {
		__prepareCanvas();

		var g = canvas.graphics;
		var a = nc_size;

		/* === Draw Background === */
		g.clear();

		g.beginFill(nc_graphics.backgroundColor);
		g.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
		g.endFill();
	}

	/**
	  * Create and configure [canvas]
	  */
	public inline function __prepareCanvas():Void {
		if (canvas != null) {
			removeChild( canvas );
		}

		canvas = new Shape();
		addChild( canvas );
	}

	/**
	  * Execute a snippet of JavaScript code
	  */
	private inline function js(code : String):Dynamic {
		return ExternalInterface.call('eval', code);
	}

/* === Instance Fields === */

	private var sprite:Sprite;

	public var resizeEvent : Signal<{then:Area, now:Area}>;
	public var frameEvent : Signal<Dynamic>;

	public var nc_graphics : TGraphics;

	/**
	  * The Shape instance which we will use to draw on
	  */
	public var canvas:Shape;
	
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
