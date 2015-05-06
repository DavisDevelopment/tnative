package tannus.geom;

import tannus.ds.TwoTuple;
import tannus.geom.Rectangle;

abstract Area (TwoTuple<Float, Float>) {
	public inline function new(w:Float=0, h:Float=0):Void {
		this = new TwoTuple(w, h);
	}

	/* 'width' field */
	public var width(get, set):Float;
	private inline function get_width() return this.one;
	private inline function set_width(nw:Float) return (this.one = nw);

	/* 'height' field */
	public var height(get, set):Float;
	private inline function get_height() return (this.two);
	private inline function set_height(nh:Float) return (this.two = nh);

/* === Instance Methods === */

	/**
	  * Create and Return a copy of [this]
	  */
	public inline function clone():Area {
		return new Area(width, height);
	}

/* === Type Casting === */

	/* To Rectangle */
	@:to
	public function toRectangle():tannus.geom.Rectangle {
		return new Rectangle(0, 0, width, height);
	}

	/* To String */
	@:to
	public function toString():String {
		return 'Area(width=$width, height=$height)';
	}

	#if java
	/* To java.awt.Dimension */
	@:to
	public function toJavaDimension():java.awt.Dimension {
		return new java.awt.Dimension(i(width), i(height));
	}

	@:from
	public static function fromJavaDimension(d : java.awt.Dimension):Area {
		return new Area(d.width, d.height);
	}
	#end

	private static inline function i(f:Float):Int return Math.round(f);
}

class OldArea {
	/* Constructor Function */
	public function new(w:Float=0, h:Float=0):Void {
		width = w;
		height = h;
	}

/* === Instance Methods === */

	public var width : Float;
	public var height : Float;
}
