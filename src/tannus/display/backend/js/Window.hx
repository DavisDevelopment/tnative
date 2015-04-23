package tannus.display.backend.js;

import tannus.display.backend.js.*;
import tannus.display.TWindow;
import tannus.display.TGraphics;
import tannus.graphics.Color;
import tannus.geom.Area;
import tannus.io.Signal;

import tannus.events.MouseEvent;

import js.html.Document;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;

class Window implements TWindow {
	/* Constructor Function */
	public function new():Void {
		instance = this;

		//- Create Event Signals
		resizeEvent = new Signal();
		frameEvent = new Signal();
		mouseEvent = new Signal();
		
		//- Create a new Canvas
		canvas = cast doc.createElement( 'canvas' );
		ctx = canvas.getContext('2d');
		nc_graphics = new TannusGraphics( this );

		__init();
	}

/* === Instance Methods === */

	/**
	  * Initialize [this] Window
	  */
	private inline function __init():Void {
		
		//- add my canvas to the window
		doc.body.appendChild( canvas );
		
		//- Make [canvas] occupy entire browser window
		makeFullScreen( canvas );

		__bindEvents();
		__frameLoop();
	}

	/**
	  * Bind all useful Events into the Tannus System
	  */
	private function __bindEvents():Void {
		var ebinder = new EventBinder( this );
		ebinder.bind();
	}

	/**
	  * Initiate the Frame-Loop
	  */
	private function __frameLoop():Void {
		/**
		  * We'll use [setInterval] for now, 
		  * but we'll need to use requestAnimationFrame later
		  */
		win.setInterval(function() {
			
			__perFrameInternal();
			frameEvent.broadcast(null);
		}, 30);

	}

	/**
	  * Nitty Gritty stuff that should happen every frame
	  */
	private inline function __perFrameInternal():Void {
		//- Get the 'background color' of [this] Window
		var bg:Color = nc_graphics.backgroundColor;

		//- Clear the Canvas
		ctx.clearRect(0, 0, canvas.width, canvas.height);

		//- Begin a new Path
		ctx.beginPath();

		//- Fill the entire canvas with the 'background color'
		ctx.fillStyle = bg;
		ctx.fillRect(0, 0, canvas.width, canvas.height);
		ctx.closePath();
	}

	/**
	  * Make the canvas take up the full window
	  */
	//@:allow(tannus.display.backend.js.EventBinder)
	public function makeFullScreen(can : CanvasElement):Void {
		can.width = win.innerWidth;
		can.height = win.innerHeight;
	}


/* === Computed Instance Fields === */

	private var d(get, never):Document;
	private inline function get_d() return js.Browser.document;
	
	private var doc(get, never):Dynamic;
	private inline function get_doc() return js.Browser.document;

	private var win(get, never):js.html.Window;
	private inline function get_win() return js.Browser.window;

	/* Window Title */
	public var nc_title(get, set):String;
	private inline function get_nc_title() return d.title;
	private inline function set_nc_title(nt:String) return (d.title = nt);

	/* Window Size */
	public var nc_size(get, set):Area;
	private inline function get_nc_size() return new Area(win.innerWidth, win.innerHeight);
	private inline function set_nc_size(ns : Area):Area {
		return nc_size;
	}


/* === Fields === */

	//- Reference to THE instance of Window
	public static var instance:Null<Window> = null;

	//- The Canvas in use by [this] Window
	public var canvas : CanvasElement;

	//- The Rendering Context used by [this] Window
	public var ctx : CanvasRenderingContext2D;

	//- Event fired when the Window is resized
	public var resizeEvent : Signal<{then:Area, now:Area}>;

	//- Event fired before the rendering of each frame
	public var frameEvent : Signal<Dynamic>;

	//- Event fired for mouse-events
	public var mouseEvent : Signal<MouseEvent>;

	//- Implementation of TGraphics in use by [this] Window
	public var nc_graphics : TGraphics;
}

private typedef Win = js.html.Window;
