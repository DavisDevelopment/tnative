package tannus.geom;

import tannus.math.TMath;
import tannus.math.Percent;

import tannus.geom.Point;

class Quadratic {
	/* Constructor Function */
	public function new(start:Point, ctrl:Point, end:Point):Void {
		this.start = start;
		this.ctrl = ctrl;
		this.end = end;
	}

/* === Instance Methods === */

/* === Instance Fields === */

	public var start : Point;
	public var end : Point;
	public var ctrl : Point;
}
