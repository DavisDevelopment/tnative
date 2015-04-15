package tannus.display.backend.java;

import tannus.display.backend.java.*;
import tannus.display.TGraphics;
import tannus.graphics.Color;
import tannus.io.Signal;
import tannus.io.Ptr;

class TannusGraphics implements TGraphics {
	/* Constructor Function */
	public function new(owner : Window):Void {
		win = owner;

		backgroundColor = 0;
	}

/* === Instance Fields === */

	//- Reference to the Window object [this] Graphics operates on
	private var win : Window;

	//- internal variable to store the current background color
	private var _bg : Color;

	/**
	  * The background color of [this] Graphics
	  */
	public var backgroundColor(get, set) : Color;
	private inline function get_backgroundColor():Color {
		//- return [_bg], because backgroundColor shouldn't be changable without using this interface
		return _bg;
	}
	private inline function set_backgroundColor(nc : Color):Color {
		win.setBackground( nc );
		return (_bg = nc);
	}
}
