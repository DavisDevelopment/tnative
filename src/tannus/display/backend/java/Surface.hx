package tannus.display.backend.java;

import java.javax.swing.JPanel;
import java.awt.Color;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.RenderingHints;

import tannus.io.Ptr;
import tannus.io.Signal;
import tannus.display.backend.java.Window;
import tannus.geom.Rectangle;
import tannus.geom.Area;
private typedef TColor = tannus.graphics.Color;

class Surface extends JPanel {
	/* Constructor Function */
	public function new(ref : Window):Void {
		super( true );

		win = ref;
		onPaint = new Signal();
	}

/* === Instance Methods === */

	/**
	  * Method called when [this] Surface is rendered
	  */
	@:overload
	override public function paintComponent(rg : Graphics):Void {
		super.paintComponent( rg );
		
		context = rg;

		rg.dispose();
	}

/* === Instance Fields === */

	//- reference to the Window [this] is attached to
	private var win:Window;

	//- reference to [this] Surface's Graphics object
	public var context:Graphics;

	//- Signal to fire each frame
	public var onPaint:Signal<Graphics2D>;
}
