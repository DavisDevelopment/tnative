package tannus.events;

import tannus.ds.Delta;
import tannus.geom.Area;

class ResizeEvent extends Event {
	/* Constructor Function */
	public function new(old_area:Area, new_area:Area):Void {
		super( 'resize' );

		delta = new Delta(new_area, old_area);
	}

/* === Instance Fields === */

	public var delta : Delta<Area>;
}
