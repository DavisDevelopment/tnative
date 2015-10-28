package tannus.ui;

import tannus.ds.Maybe;
import tannus.ui.BorderStyle;
import tannus.graphics.Color;

class Border {
	/* Constructor Function */
	public function new(?styl:Maybe<BorderStyle>, ?colr:Maybe<Color>, ?size:Maybe<Float>, ?radi:Maybe<Float>):Void {
		style = (styl || Solid);
		width = (size || 0);
		color = (colr || '#000');
		radius = (radi || 0);
	}

/* === Instance Fields === */

	/* The Type of Border [this] is */
	public var style : BorderStyle;

	/* The Width of [this] Border */
	public var width : Float;

	/* The Color of [this] Border */
	public var color : Color;

	/* The 'radius' of [this] Border */
	public var radius : Float;
}
