package tannus.display.backend.java;

import tannus.display.TWindow;
import tannus.geom.Area;
import tannus.graphics.Color;
import tannus.io.Ptr;
import tannus.io.Signal;

import java.lang.System;
import java.javax.swing.JFrame;
import java.awt.Graphics;

import tannus.display.backend.java.*;

class Window extends JFrame implements TWindow {
	/* Constructor Function */
	public function new():Void {
		super('Window Title');

		/* == Declare Fields == */

		surface = new Surface(this);
		mse = new java.util.concurrent.ScheduledThreadPoolExecutor(2);
		resizeEvent = new Signal();
		frameEvent = new Signal();
		nc_graphics = new TannusGraphics(this);

		__init();
	}

/* === Instance Methods === */

	/**
	  * Initialize [this] Window
	  */
	private inline function __init():Void {
		gref = Ptr.create( surface.context );

		//- enable hardware rendering
		System.setProperty("sun.java2d.opengl", "True");

		//- declare window size
		setSize(640, 480);

		//- Add 'close' Button to [this] Window
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

		//- set background color
		setBackground(JColor.black);

		//- Center the content of [this] Window
		setLocationRelativeTo(null);

		//- Add [surface] to [this] Window
		(getContentPane()).add( surface );

		setVisible(true);
		__bindEvents();
		__frameLoop();
	}

	/**
	  * Attach all *Listener instances
	  */
	private function __bindEvents():Void {
		/* == Window Events == */
		var windowEventListener = new WindowEventListener(this);
		windowEventListener.on_resize = getResizeHandler();
		addComponentListener(windowEventListener);
	}

	/**
	  * Frame Loop
	  */
	private inline function __frameLoop():Void {
		
		function frame():Void {
			//- Draw Background
			var g:Graphics = getGraphics();
			var c:Color = nc_graphics.backgroundColor;
			var s = nc_size;

			g.setColor( c );
			g.fillRect(0, 0, Std.int(s.width), Std.int(s.height));
			g.dispose();

			//- Emit 'frame' Event
			g = surface.getGraphics();
			frameEvent.broadcast( g );
			g.dispose();

			var delay:Int = cast System.currentTimeMillis()+40;
			mse.schedule(new RunnableFunction(frame), cast delay, java.util.concurrent.TimeUnit.MILLISECONDS);
		}

		frame();
	}

	/**
	  * Generates Function which handles resize events
	  */
	private function getResizeHandler():Void->Void {
		var larea:Area = nc_size;
		
		function f():Void {
			var d:Dynamic = {
				'then': larea,
				'now' : nc_size
			};
			resizeEvent.broadcast(cast d);
			larea = nc_size;

			//- Draw Background
			var g:Graphics = getGraphics();
			g.setColor(nc_graphics.backgroundColor);
			var s = nc_size;
			g.fillRect(0, 0, Std.int(s.width), Std.int(s.height));
		}

		return f;
	}

/* === Computed Instance Fields === */

	/**
	  * The current window title
	  */
	public var nc_title(get, set):String;
	private inline function get_nc_title():String {
		return (getTitle());
	}
	private inline function set_nc_title(nt : String):String {
		setTitle( nt );
		return nc_title;
	}

	/**
	  * The current dimensions of [this] Window
	  */
	public var nc_size(get, set):Area;
	private function get_nc_size():Area {
		var ns = getSize();
		return new Area(ns.width, ns.height);
	}
	private function set_nc_size(na:Area):Area {
		var r = Math.round.bind(_);
		setSize(r(na.width), r(na.height));
		return nc_size;
	}

/* === Instance Fields === */

	//- [this] Window's Panel
	public var surface:Surface;

	//- Pointer to the 'context' field of [surface]
	public var gref:Ptr<Graphics>;

	//- The timer-thing I use to schedule frame-events
	private var mse:java.util.concurrent.ScheduledThreadPoolExecutor;

	//- The event which fires when the window is resized
	public var resizeEvent:Signal<{then:Area, now:Area}>;

	//- The event which fires when a frame is about to be rendered
	public var frameEvent:Signal<Dynamic>;

	//- The Graphics object for [this] Window
	public var nc_graphics : TGraphics;
}

private typedef JColor = java.awt.Color;
