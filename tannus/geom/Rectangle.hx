package tannus.geom;

import tannus.io.Ptr;

import tannus.geom.Point;
import tannus.geom.Area;
import tannus.geom.Shape;
import tannus.geom.Vertices;

import tannus.math.Percent;
import tannus.ds.EitherType in Either;

import Math.*;
import tannus.math.TMath.*;

@:forward
abstract Rectangle (CRectangle) from CRectangle to CRectangle {
	/* Constructor Function */
	public inline function new(_x:Float=0, _y:Float=0, _width:Float=0, _height:Float=0):Void {
		this = new CRectangle(_x, _y, _width, _height);
	}

/* === Operators === */

	/* Equality Testing */
	@:op(A == B)
	public inline function eq(o : Rectangle):Bool {
		return this.equals( o );
	}

	/* Division */
	@:op(A / B)
	public inline function floatDiv(o : Float):Rectangle {
		return this.divide( o );
	}

	/* Division by Rectangle */
	@:op(A / B)
	public inline function rectDiv(r : Rectangle):Rectangle {
		return this.divide( r );
	}

/* === Type Casting === */

	#if flash
	
	/* To flash.geom.Rectangle */
	@:to
	public inline function toFlashRect():flash.geom.Rectangle {
		return new flash.geom.Rectangle(this.x, this.y, this.width, this.height);
	}

	/* From flash.geom.Rectangle */
	@:from
	public static inline function fromFlashRect(fr : flash.geom.Rectangle):Rectangle {
		return new Rectangle(fr.x, fr.y, fr.width, fr.height);
	}

	#end

	/**
	  * Create a Rectangle from an Array of Numbers
	  */
	@:from
	public static inline function fromArray<T : Float> (a : Array<T>):Rectangle {
		return new Rectangle(a[0], a[1], a[2], a[3]);
	}
}

class CRectangle implements Shape {
	public function new(_x:Float=0, _y:Float=0, _width:Float=0, _height:Float=0):Void {
		x = _x;
		y = _y;
		z = 0;
		width = _width;
		height = _height;
		depth = 0;
	}

/* === Instance Methods === */

	/**
	  * Creates and returns a clone of [this] Rectangle
	  */
	public function clone():Rectangle {
		var r:Rectangle = new Rectangle(x, y, width, height);
		r.z = z;
		r.depth = depth;
		return r;
	}

	/**
	  * Copies data from [other] onto [this]
	  */
	public function cloneFrom(other : Rectangle):Void {
		x = other.x;
		y = other.y;
		z = other.z;
		width = other.width;
		height = other.height;
		depth = other.depth;
	}

	/**
	  * Whether [other] Rectangle is equal to [this] one
	  */
	public function equals(other : Rectangle):Bool {
		return (
			x == other.x &&
			y == other.y &&
			z == other.z &&
			width == other.width &&
			height == other.height &&
			depth == other.depth
		);
	}

	/**
	  * Divide [this] Rectangle
	  */
	public function divide(div : Either<Float, Rectangle>):Rectangle {
		switch (div.type) {
			case Left( f ):
				return new Rectangle(x, y, w/f, h/f);

			case Right( r ):
				return new Rectangle(x, y, w/r.w, h/r.h);
		}
	}

	/**
	  * Whether [ox] and [oy] describe a point which is 'inside' [this] Rectangle
	  */
	public inline function contains(ox:Float, oy:Float):Bool {
		return (
			(ox > x && (ox < (x + w))) &&
			(oy > y && (oy < (y + h)))
		);
	}

	/**
	  * Whether [point] is 'inside' [this] Rectangle
	  */
	public inline function containsPoint(point : Point):Bool {
		return contains(point.x, point.y);
	}
	
	/**
	  * Whether [rect] is 'inside' [this] Rectangle
	  */
	public function containsRect(o : Rectangle):Bool {
		if (containsPoint(o.center)) {
			return true;
		}
		else {
			for (p in o.corners) {
				if (containsPoint( p )) {
					return true;
				}
			}
			return false;
		}
	}

	/**
	  * Enlarge [this] Rectangle by the given amount
	  */
	public function enlarge(dw:Float, dh:Float):Void {
		w += dw;
		h += dh;
		x -= (dw / 2);
		y -= (dh / 2);
	}

	/**
	  * Move [this] Rectangle by the given amount
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
	  * Vectorize [this] Rectangle
	  */
	public function vectorize(r : Rectangle):Rectangle {
		var pos:Point = topLeft.vectorize( r );
		var dim:Area = new Area(perc(w, r.w), perc(h, r.h));

		return new Rectangle(pos.x, pos.y, dim.width, dim.height);
	}

	/**
	  * Devectorize [this] Rectangle
	  */
	public function devectorize(r : Rectangle):Rectangle {
		var px:Percent = x, py:Percent = y, pw:Percent = w, ph:Percent = h;

		return new Rectangle(px.of(r.w), py.of(r.h), pw.of(r.w), ph.of(r.h));
	}

	/**
	  * Obtain [this] Rect's vertices
	  */
	public function getVertices():Vertices {
		var self:Rectangle = cast this;

		var verts = new Vertices([
			self.topLeft,
			self.topRight,
			self.bottomRight, 
			self.bottomLeft
		]);

		return verts;
	}

	/**
	  * Obtain an Array of Pointers to the corners of [this] Rectangle
	  */
	public function getCornerPointers():Array<Ptr<Point>> {
		var result:Array<Ptr<Point>> = [
			Ptr.create( topLeft ),
			Ptr.create( topRight ),
			Ptr.create( bottomLeft ),
			Ptr.create( bottomRight )
		];
		return result;
	}

	/**
	  * get an Array of Rectangles, representing the z-layers of [this] one
	  */
	public function layers():Array<Rectangle> {
		var results:Array<Rectangle> = new Array();
		for (i in round(z)...round(z + depth)) {
			var layer = new Rectangle(x, y, w, h);
			layer.z = i;
			results.push( layer );
		}
		return results;
	}

	/**
	  * Convert into a human-readable String
	  */
	public inline function toString():String {
		return 'Rectangle($x, $y, $w, $h)';
	}


/* === Computed Instance Fields === */

	/**
	  * The position of [this] Rectangle as a Point
	  */
	public var position(get, set):Point;
	private inline function get_position():Point {
		return new Point(x, y, z);
	}
	private inline function set_position(np : Point):Point {
		x = np.x;
		y = np.y;
		z = np.z;
		return position;
	}

	/**
	  * An Array of all corners of [this] Rectangle
	  */
	public var corners(get, never):Array<Point>;
	private function get_corners():Array<Point> {
		return [topLeft, topRight, bottomLeft, bottomRight];
	}

	/**
	  * [this] Rectangle's Area as a Float
	  */
	public var area(get, never):Float;
	private inline function get_area():Float {
		return (width * height);
	}

	/* the center of [this] Rectangle along the x-axis */
	public var centerX(get, set):Float;
	private inline function get_centerX():Float {
		return (x + (w / 2));
	}
	private inline function set_centerX(v : Float) {
		return (x = (v - (w / 2)));
	}

	/* the center of [this] Rectangle along the y-ayis */
	public var centerY(get, set):Float;
	private inline function get_centerY():Float {
		return (y + (h / 2));
	}
	private inline function set_centerY(v : Float) {
		return (y = (v - (h / 2)));
	}

	/**
	  * Point representing the 'center' of [this] Rectangle
	  */
	public var center(get, set):Point;
	private inline function get_center():Point {
		return new Point(centerX, centerY);
	}
	private function set_center(nc : Point):Point {
		centerX = nc.x;
		centerY = nc.y;
		return nc;
	}

	/**
	  * The top-right corner
	  */
	public var topRight(get, set):Point;
	private inline function get_topRight():Point {
		return new Point((x + width), y);
	}
	private function set_topRight(v : Point):Point {
		x = (v.x - width);
		y = v.y;
		return topRight;
	}

	/**
	  * The top-left corner
	  */
	public var topLeft(get, set):Point;
	private inline function get_topLeft():Point {
		return new Point(x, y);
	}
	private function set_topLeft(v : Point):Point {
		x = v.x;
		y = v.y;
		return topLeft;
	}

	/**
	  * The bottom-left corner
	  */
	public var bottomLeft(get, set):Point;
	private inline function get_bottomLeft():Point {
		return new Point(x, (y + height));
	}
	private function set_bottomLeft(v : Point):Point {
		x = v.x;
		y = (v.y - height);
		return bottomLeft;
	}

	/**
	  * The bottom-right
	  */
	public var bottomRight(get, set):Point;
	private inline function get_bottomRight():Point {
		return new Point((x + width), (y + height));
	}
	private function set_bottomRight(v : Point):Point {
		x = (v.x - w);
		y = (v.y - h);
		return bottomRight;
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

	/**
	  * Alias for 'depth' as 'd'
	  */
	public var d(get, set):Float;
	private inline function get_d() return depth;
	private inline function set_d(nd : Float) return (depth = nd);

/* === Instance Fields === */

	public var x:Float;
	public var y:Float;
	public var z:Float;
	public var width:Float;
	public var height:Float;
	public var depth:Float;

/* === Class Methods === */

	/**
	  * Shorthand to create a Percent
	  */
	private static inline function perc(what:Float, of:Float):Percent {
		return Percent.percent(what, of);
	}
}
