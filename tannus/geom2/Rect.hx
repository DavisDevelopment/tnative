package tannus.geom2;

import tannus.ds.DataView;

import Std.*;
import tannus.math.TMath.*;

using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;

class Rect <T:Float> {
	/* Constructor Function */
	public function new(?x:T, ?y:T, ?width:T, ?height:T):Void {
		d = new DataView(4, untyped 0);

		if (x == null) x = untyped 0;
		if (y == null) y = untyped 0;
		if (width == null) width = untyped 0;
		if (height == null) height = untyped 0;

		d.sets([x, y, width, height]);
	}

/* === Instance Methods === */

	/**
	  * create and return a deep-copy of [this]
	  */
	public inline function clone():Rect<T> {
		return new Rect(x, y, w, h);
	}

	/**
	  * copy data from the given Rect<T>
	  */
	public function pull(src : Rect<T>):Void {
		x = src.x;
		y = src.y;
		w = src.w;
		h = src.h;
	}

	/**
	  * test whether [this] Rect is equal to [other]
	  */
	public function equals(o : Rect<T>):Bool {
		return (
			(x == o.x) &&
			(y == o.y) &&
			(w == o.w) &&
			(h == o.h)
		);
	}

	/**
	  * check whether the given coordinates fall within [this] Rect
	  */
	public function contains(ox:Float, oy:Float):Bool {
		return (
			(ox > x && (ox < (x + w))) &&
			(oy > y && (oy < (y + h)))
		);
	}

	/**
	  * check whether the given Point falls within [this] Rect
	  */
	public inline function containsPoint(p : Point<Float>):Bool {
		return contains(p.x, p.y);
	}

	/**
	  * get the corners of [this] Rect
	  */
	public function getCorners():Array<Point<T>> {
		return [topLeft, topRight, bottomLeft, bottomRight];
	}

	/**
	  * check whether the given Rect is completely inside of [this] one
	  */
	public function containsRect(o : Rect<Float>):Bool {
		var ocl = o.getCorners();
		for (p in ocl) {
			if (!containsPoint( p )) {
				return false;
			}
		}
		return true;
	}

	/**
	  * check whether [this] Rect overlaps at all with the given one
	  */
	public function overlapsWith(o : Rect<Float>):Bool {
		var ocl = o.getCorners();
		if (containsPoint( o.center )) {
			return true;
		}
		else {
			for (p in o.getCorners()) {
				if (containsPoint( p )) {
					return true;
				}
			}
			return false;
		}
	}

	/**
	  * modify the size of [this] Rect
	  */
	public function enlarge(dw:T, dh:T):Void {
		w += dw;
		h += dh;
		x -= Math.round(dw / 2);
		y -= Math.round(dh / 2);
	}

	/**
	  * Convert [this] Rect to a String
	  */
	public inline function toString():String {
		return 'Rect($x, $y, $width, $height)';
	}

	/**
	  * Convert [this] into an Array
	  */
	public inline function toArray():Array<T> {
		return [x, y, w, h];
	}

	public inline function toRectangle():tannus.geom.Rectangle 
		return tannus.geom.Rectangle.fromRect2D( this );

	/**
	  * Scale [this] Rect
	  */
	public function scale(?sw:Float, ?sh:Float):Rect<Float> {
		if (sw != null) {
			var ratio:Float = (sw / width);
			return cast new Rect(x, y, untyped sw, untyped (ratio * height));
		}
		else if (sh != null) {
			var ratio:Float = (sh / height);
			return cast new Rect(x, y, untyped (ratio * width), untyped sh);
		}
		else {
			return cast new Rect(x, y, w, h);
		}
	}

	/**
	  * Round [this] Rect
	  */
	public inline function round():Rect<Int> return apply(untyped Math.round);
	public inline function floor():Rect<Int> return apply(untyped Math.floor);
	public inline function ceil():Rect<Int> return apply(untyped Math.ceil);

	/**
	  * apply the given function to all values in [this] Rect
	  */
	private inline function apply<A:Float>(f : T->A):Rect<A> {
		return new Rect(f(x), f(y), f(w), f(h));
	}

/* === Computed Instance Fields === */

	public var x(get, set):T;
	private inline function get_x():T return d[0];
	private inline function set_x(v : T):T return (d[0] = v);
	
	public var y(get, set):T;
	private inline function get_y():T return d[1];
	private inline function set_y(v : T):T return (d[1] = v);
	
	public var width(get, set):T;
	private inline function get_width():T return d[2];
	private inline function set_width(v : T):T return (d[2] = v);
	
	public var height(get, set):T;
	private inline function get_height():T return d[3];
	private inline function set_height(v : T):T return (d[3] = v);
	
	public var w(get, set):T;
	private inline function get_w():T return d[2];
	private inline function set_w(v : T):T return (d[2] = v);
	
	public var h(get, set):T;
	private inline function get_h():T return d[3];
	private inline function set_h(v : T):T return (d[3] = v);

	public var topLeft(get, set):Point<T>;
	private inline function get_topLeft():Point<T> return new Point(x, y);
	private function set_topLeft(p : Point<T>):Point<T> {
		x = p.x;
		y = p.y;
		return topLeft;
	}

	public var topRight(get, set):Point<T>;
	private inline function get_topRight():Point<T> {
		return new Point((x + w), y);
	}
	private function set_topRight(p : Point<T>):Point<T> {
		x = untyped (p.x - w);
		y = p.y;
		return topRight;
	}

	public var bottomLeft(get, set):Point<T>;
	private inline function get_bottomLeft():Point<T> {
		return new Point(x, (y + h));
	}
	private function set_bottomLeft(p : Point<T>):Point<T> {
		x = p.x;
		y = untyped (p.y - h);
		return bottomLeft;
	}

	public var bottomRight(get, set):Point<T>;
	private inline function get_bottomRight():Point<T> {
		return new Point((x + w), (y + h));
	}
	private function set_bottomRight(p : Point<T>):Point<T> {
		x = untyped (p.x - w);
		y = untyped (p.y - h);
		return bottomRight;
	}

	public var centerX(get, set):Float;
	private inline function get_centerX():Float return (x + (w / 2));
	private function set_centerX(v : Float):Float {
		x = cast Math.round(v - ((cast w) / 2));
		return centerX;
	}

	public var centerY(get, set):Float;
	private inline function get_centerY():Float return (y + (h / 2));
	private function set_centerY(v : Float):Float {
		y = cast Math.round(v - ((cast h) / 2));
		return centerY;
	}

	public var center(get, set):Point<Float>;
	private function get_center():Point<Float> {
		var z:Float = 0;
		return LinkedPoint.create(centerX, centerY, z);
	}
	private function set_center(v : Point<Float>):Point<Float> {
		centerX = v.x;
		centerY = v.y;
		return center;
	}

/* === Instance Fields === */

	private var d : DataView<T>;
}
