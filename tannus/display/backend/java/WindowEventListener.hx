package tannus.display.backend.java;

import tannus.io.Ptr;
import tannus.geom.Area;
import tannus.geom.Point;
import tannus.display.backend.java.Window;

import java.awt.event.ComponentListener;
import java.awt.event.ComponentEvent;

class WindowEventListener implements ComponentListener {
	/* Constructor Function */
	public function new(ref : Window):Void {
		win = ref;

		on_resize = (function() null);
	}

/* === Instance Fields === */

	private var win:Window;
	public var on_resize:Null<Void -> Void>;

/* === Instance Methods === */

	/* Window Resized */
	public function componentResized(event : ComponentEvent):Void {
		on_resize();
	}

	/* Window Moved */
	public function componentMoved(event : ComponentEvent):Void {
		null;
	}

	public function componentHidden(event : ComponentEvent):Void {
		null;
	}

	public function componentShown(event : ComponentEvent):Void {
		null;
	}
}
