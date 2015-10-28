package tannus.graphics;

import tannus.math.Percent;
import tannus.graphics.Color;

/**
  * Object to represent a Color Stop in a Gradient
  */
class GraphicsColorStop {
	/* Constructor Function */
	public function new(offs:Percent, col:Color):Void {
		offset = offs;
		color = col;
	}

/* === Instance Fields === */

	/**
	  * The offset (represented as a percentage) of [this] Color Stop
	  */
	public var offset : Percent;

	/**
	  * The color of [this] Color Stop
	  */
	public var color : Color;
}
