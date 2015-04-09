package tannus.geom;

import tannus.geom.Point;
import tannus.geom.Area;

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
}

class CRectangle {
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
		//- For every corner of [o]
		for (p in o.corners) {
			//- Check whether [this] contains that corner
			if (containsPoint(p)) {
				return true;
			}
		}
		return false;
	}


/* === Computed Instance Fields === */

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

	/**
	  * The top-right corner
	  */
	public var topRight(get, never):Point;
	private inline function get_topRight():Point {
		return new Point((x + width), y);
	}

	/**
	  * The top-left corner
	  */
	public var topLeft(get, never):Point;
	private inline function get_topLeft():Point {
		return new Point(x, y);
	}

	/**
	  * The bottom-left corner
	  */
	public var bottomLeft(get, never):Point;
	private inline function get_bottomLeft():Point {
		return new Point(x, (y + height));
	}

	/**
	  * The bottom-right
	  */
	public var bottomRight(get, never):Point;
	private inline function get_bottomRight():Point {
		return new Point((x + width), (y + height));
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
}
