package tannus.graphics;

import tannus.graphics.Color;
import tannus.graphics.LineCap;
import tannus.graphics.LineJoin;

/**
  * Class to represent the styling for lines
  */
class LineStyle {
	/* Constructor Function */
	public function new():Void {
		width = DEFAULT_WIDTH;
		color = DEFAULT_COLOR;
		cap = DEFAULT_CAP;
		join = DEFAULT_JOIN;
	}

/* === Instance Methods === */

	/**
	  * restore [this] LineStyle to it's default state
	  */
	public inline function reset():Void {
		width = DEFAULT_WIDTH;
		color = DEFAULT_COLOR;
		cap = DEFAULT_CAP;
		join = DEFAULT_JOIN;
	}

	/**
	  * create and return a copy of [this] LineStyle
	  */
	public inline function clone():LineStyle {
		var c = new LineStyle();
		c.width = width;
		c.color = color.clone();
		c.cap = cap;
		c.join = join;

		return c;
	}

/* === Instance Fields === */

	//- The width of drawn lines
	public var width : Float;

	//- The color of drawn lines
	public var color : Color;

	//- The joint type of drawn lines
	public var join : LineJoin;

	//- The capping type of drawn lines
	public var cap  : LineCap;


/* === Static Fields === */

	public static var DEFAULT_WIDTH:Float = 2;
	
	public static var DEFAULT_COLOR:Color = {new Color(0, 0, 0);};

	public static var DEFAULT_JOIN:LineJoin = {LineJoin.Miter;};

	public static var DEFAULT_CAP:LineCap = {LineCap.Butt;};
}
