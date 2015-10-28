package tannus.display.backend.java;

import java.javax.swing.JPanel;
import java.awt.Color;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.event.MouseEvent;

import tannus.display.backend.java.*;

import tannus.io.Ptr;
import tannus.io.Signal;
import tannus.geom.Rectangle;
import tannus.geom.Area;
private typedef TColor = tannus.graphics.Color;

class Surface extends JPanel {
	/* Constructor Function */
	public function new(ref : Window):Void {
		super( true );

		win = ref;

		mouseListener = new MouseEventListener( win );

		addMouseListener( mouseListener );
		addMouseMotionListener( mouseListener );

		onPaint = new Signal();
	}

/* === Instance Methods === */

	/**
	  * Method called when [this] Surface is rendered
	  */
	@:overload
	override public function paintComponent(rg : Graphics):Void {
		super.paintComponent( rg );

		var g:Graphics2D = (cast rg);

		/* Draw Background */
		var c:TColor = win.nc_graphics.backgroundColor;
		var s = win.nc_size;

		g.setColor( c );
		g.fillRect(0, 0, Std.int(s.width), Std.int(s.height));

		/* Draw Any Queued Paths */
		win.frameEvent.broadcast( g );
		
		rg.dispose();
	}

	/**
	  * Listener for Mouse Events
	  */
	@:overload
	override public function processMouseEvent(event:MouseEvent):Void {
		super.processMouseEvent(event);
	}

/* === Instance Fields === */

	//- reference to the Window [this] is attached to
	private var win:Window;

	//- reference to [this] Surface's Graphics object
	public var context:Graphics;

	//- Signal to fire each frame
	public var onPaint:Signal<Graphics2D>;

	//- MouseEventListener instance, attached to [this] Surface
	public var mouseListener : MouseEventListener;
}
