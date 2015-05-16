package tannus.graphics;

import tannus.io.Ptr;
import tannus.io.Getter;
import tannus.graphics.Color;
import tannus.graphics.Image;
import tannus.geom.Point;

@:access(tannus.graphics.Image)
abstract PixelArray (Image) {
	@:allow(tannus.graphics.Image)
	/* Constructor Function */
	private inline function new(img : Image):Void {
		this = img;
	}

/* === Instance Methods === */

	/**
	  * Get the color of the pixel at the given Point
	  */
	@:arrayAccess
	public function getPixel(pq : PxlG):Null<Color> {
		switch (pq.t()) {
			case GInt( index ):

		}
	}

/* === Instance Fields === */

	/**
	  * The Number of Pixels in [this] PixelArray
	  */
	public var length(get, never):Int;
	private inline function get_length() return (this.width * this.height);
}

/**
  * Abstract which allows array-access to be performed with either a Point, or an Int
  */
abstract PxlG (Epg) {
	public inline function new(g : Epg) {
		this = g;
	}

	@:to
	public inline function t() return this;

	@:from
	public static inline function fromInt(i : Int):PxlG {
		return new PxlG(GInt(i));
	}

	@:from
	public static inline function fromPoint(p : Point):PxlG {
		return new PxlG(GPoint(p));
	}

	@:from
	public static inline function fromArray(a : Array<Float>):PxlG {
		return new PxlG(GPoint(a));
	}
}

private enum Epg {
	GInt(i : Int);
	GPoint(pt : Point);
}
