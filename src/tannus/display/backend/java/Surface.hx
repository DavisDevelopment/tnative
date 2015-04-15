package tannus.display.backend.java;

import java.javax.swing.JPanel;
import java.awt.Color;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.RenderingHints;

import tannus.io.Ptr;
import tannus.display.backend.java.Window;
import tannus.geom.Rectangle;
import tannus.geom.Area;
private typedef TColor = tannus.graphics.Color;

class Surface extends JPanel {
	/* Constructor Function */
	public function new(ref : Window):Void {
		super( true );

		win = ref;
	}

/* === Instance Methods === */

	/**
	  * Method called when [this] Surface is rendered
	  */
	@:overload
	override public function paintComponent(rg : Graphics):Void {
		super.paintComponent( rg );
		
		context = rg;

		//- Draw the Background
		var g:Graphics2D = cast rg;
		var bg:TColor = win.nc_graphics.backgroundColor;
		g.setColor( bg );

		var s:Area = win.nc_size;
		var i = Math.round.bind(_);
		g.fillRect(0, 0, i(s.width), i(s.height));
	}

/* === Instance Fields === */

	//- reference to the Window [this] is attached to
	private var win:Window;

	//- reference to [this] Surface's Graphics object
	public var context:Graphics;
}
