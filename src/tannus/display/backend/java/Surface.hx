package tannus.display.backend.java;

import java.javax.swing.JPanel;
import java.awt.Color;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.RenderingHints;

import tannus.io.Ptr;
import tannus.display.backend.java.Window;

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

		var g:Graphics2D = cast rg;

	}

/* === Instance Fields === */

	//- reference to the Window [this] is attached to
	private var win:Window;

	//- reference to [this] Surface's Graphics object
	public var context:Graphics;
}
