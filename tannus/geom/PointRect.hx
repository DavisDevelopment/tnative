package tannus.geom;

import tannus.io.Ptr;

import tannus.math.Percent;
import tannus.ds.EitherType in Either;

import Math.*;
import tannus.math.TMath.*;

using Lambda;
using tannus.ds.ArrayTools;
using StringTools;
using tannus.ds.StringUtils;
using tannus.math.TMath;
using tannus.macro.MacroTools;

@:forward
abstract PointRect (CPointRect) from CPointRect to CPointRect {
	/* Constructor Function */
	public inline function new(?x:Float, ?y:Float, ?w:Float, ?h:Float):Void {
		this = new CPointRect(x, y, w, h);
	}

/* === Casting Methods === */

	/* Cast from a Rectangle */
	@:from
	public static inline function fromRectangle(r : Rectangle):PointRect {
		return new PointRect(r.x, r.y, r.w, r.h);
	}

	/* Cast to a Rectangle */
	@:to
	public inline function toRectangle():Rectangle {
		return new Rectangle(this.x, this.y, this.width, this.height);
	}
}

class CPointRect extends Quadrilateral {
	/* Constructor Function */
	public function new(xx:Float=0, yy:Float=0, ww:Float=0, hh:Float=0):Void {
		super();

		x = xx;
		y = yy;
		width = ww;
		height = hh;
	}

/* === Instance Fields === */

	/**
	  * clone [this] Rect
	  */
	public function clone():PointRect {
		return new PointRect(x, y, width, height);
	}

	/**
	  * copy data from [other]
	  */
	public function cloneFrom(other : PointRect):Void {
		x = other.x;
		y = other.y;
		w = other.w;
		h = other.h;
	}

	/**
	  * Whether [other] Rect is equal to [this]
	  */
	public inline function equals(o : PointRect):Bool {
		return (
			x == o.x &&
			y == o.y &&
			w == o.w &&
			h == o.h
		);
	}

	/**
	  * Whether [this] contains the given coordinates
	  */
	public inline function contains(ox:Float, oy:Float):Bool {
		return (
			(ox > x && (ox < (x + w))) &&
			(oy > y && (oy < (y + h)))
		);
	}

	/**
	  * Whether [this] contains the given Point
	  */
	public inline function containsPoint(p : Point):Bool {
		return contains(p.x, p.y);
	}

	/**
	  *  enlarge [this] Rect
	  */
	public function enlarge(dw:Float, dh:Float):Void {
		w += dw;
		h += dh;
		x -= (dw / 2);
		y -= (dh / 2);
	}

	/**
	  * move [this] Rect
	  */
	public function move(dx:Float, dy:Float):Void {
		x += dx;
		y += dy;
	}

	/**
	  * Scale [this] Rectangle such that the relationship between [w] and [h] remain the same
	  */
	public function scale(?sw:Float, ?sh:Float):Void {
		if (sw != null) {
			var ratio:Float = (sw / width);
			width = sw;
			height = (ratio * height);
		}
		else if (sh != null) {
			var ratio:Float = (sh / height);
			width = (ratio * width);
			height = sh;
		}
		else {
			return ;
		}
	}

	/**
	  * create and return a scaled copy of [this]
	  */
	public function scaled(?sw:Float, ?sh:Float):Rectangle {
		var s:Rectangle = clone();
		s.scale(sw, sh);
		return s;
	}

	/**
	  * Scale [this] Rectangle to be [amount]% of its current size
	  */
	public function percentScale(amount : Percent):Void {
		w = amount.of( w );
		h = amount.of( h );
	}

	/**
	  * Create and return a scaled version of [this] Rectangle
	  */
	public inline function percentScaled(amount : Percent):Rectangle {
		return new Rectangle(x, y, amount.of( w ), amount.of( h ));
	}

	/**
	  * Split [this] Rectangle into [count] pieces, either vertically or horizontally
	  */
	public function split(count:Int, vertical:Bool=true):Array<PointRect> {
		var all:Array<PointRect> = new Array();
		if ( vertical ) {
			var ph:Float = (h / count);
			for (i in 0...count) {
				all.push(new PointRect(x, (y + (i * ph)), w, ph));
			}
		}
		else {
			var pw:Float = (w / count);
			for (i in 0...count) {
				all.push(new PointRect((x + (i * pw)), y, pw, h));
			}
		}
		return all;
	}

	/**
	  * Split [this] Rectangle into [count]^2 pieces, stored in a two-dimensional Array
	  */
	public function split2(count : Int):Array<Array<PointRect>> {
		return split(count, true).map(function(r) return r.split(count, false));
	}

	/**
	  * bisect [this] Rectangle into two Triangles
	  */
	public function bisect(mode : Bool = true):Array<Triangle> {
		var pair:Array<Triangle> = new Array();
		if ( mode ) {
			pair.push(new Triangle(a, b, c));
			pair.push(new Triangle(a, d, c));
		}
		else {
			pair.push(new Triangle(b, c, d));
			pair.push(new Triangle(d, a, b));
		}
		return pair;
	}

	/**
	  * bisect [this] Rectangle into four Triangles
	  */
	public function bisect2():Array<Triangle> {
		return bisect().map(function(t) return t.bisect()).flatten();
	}

/* === Computed Instance Fields === */

	/* the x coordinate of [this] Rect */
	public var x(get, set):Float;
	private inline function get_x():Float return a.x;
	private function set_x(v : Float):Float {
		var d:Float = (v - x);
		data.each(_.x += d);
		return x;
	}

	/* the y coordinate of [this] Rect */
	public var y(get, set):Float;
	private inline function get_y():Float return a.y;
	private function set_y(v : Float):Float {
		var d = (v - y);
		data.each(_.y += d);
		return y;
	}

	/* the width of [this] Rect */
	public var width(get, set):Float;
	private inline function get_width():Float return (b.x - a.x);
	private inline function set_width(v : Float):Float {
		return ((c.x = b.x = (a.x + v)) - a.x);
	}

	/* the height of [this] Rect */
	public var height(get, set):Float;
	private inline function get_height():Float return (d.y - a.y);
	private inline function set_height(v : Float):Float {
		return ((c.y = d.y = (a.y + v)) - a.y);
	}

	/**
	  * Alias for 'width' as 'w'
	  */
	public var w(get, set):Float;
	private inline function get_w() return width;
	private inline function set_w(nw:Float) return (width = nw);

	/**
	  * Alias for 'height' as 'h'
	  */
	public var h(get, set):Float;
	private inline function get_h() return height;
	private inline function set_h(nh : Float) return (height = nh);
}
