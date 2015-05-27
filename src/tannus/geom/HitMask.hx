package tannus.geom;

import tannus.ds.IntRange;
import tannus.geom.Point;
import tannus.geom.Rectangle;

class HitMask {
	/* Constructor Function */
	public function new(rec:Rectangle, ranga:Ranges):Void {
		rect = rec;
		ranges = ranga;
	}

/* === Instance Methods === */

	/**
	  * Test whether a Point is 'inside' [this] HitMask
	  */
	public function testPoint(pos : Point):Bool {
		if (rect.containsPoint(pos)) {
			var xr:Null<IntRange> = ranges[pos.iy];
			if (xr != null) {
				return xr.contains(pos.ix);
			}
			else
				return false;
		}
		else
			return false;
	}

/* === Instance Fields === */

	public var rect:Rectangle;

	public var ranges:Ranges;
}

private typedef Ranges = Map<Int, IntRange>;
