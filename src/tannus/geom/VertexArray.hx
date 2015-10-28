package tannus.geom;

import tannus.ds.Stack;
import tannus.ds.FloatRange;
import tannus.ds.Pair;

import tannus.geom.*;
import tannus.geom.Point;

using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;

class VertexArray {
	/* Constructor Function */
	public function new(?v : Array<Point>):Void {
		data = (v != null ? [for (p in v) toImmutable(p)] : new Array());
		_lines = new Pair(null, null);
		_rect = null;
	}

/* === Instance Methods === */

	/**
	  * Reset any cached values, so that they must be calculated again
	  */
	private function resetCache():Void {
		_lines = new Pair(null, null);
		_rect = null;
	}

	/**
	  * Get the Point at index [i]
	  */
	public function get(i : Int):Null<Point> {
		return (data[ i ]);
	}

	/**
	  * Set the Point at index [i]
	  */
	public function set(i:Int, p:Point):Point {
		data[i] = toImmutable( p );
		resetCache();

		return get( i );
	}

	/**
	  * Convert a given Point to an ImmutablePoint 
	  */
	private function toImmutable(p : Point):Point {
		if (!Std.is(p, ImmutablePoint)) {
			var np:Point = cast new ImmutablePoint(p.x, p.y, p.z);
			return np;
		}
		else return p.clone();
	}

	/**
	  * Convert a given Point which is Immutable to a regular Point
	  */
	private function toMutable(p : Point):Point {
		if (Std.is(p, ImmutablePoint)) {
			var np:Point = new Point();
			np.copyFrom( p );
			return np;
		}
		else return p;
	}

	/**
	  * Iterate over [this] VertexArray
	  */
	public function iterator():Iterator<Point> {
		return new VerticeIterator( this );
	}

	/**
	  * Add a new Point to the end of [this] VertexArray
	  */
	public function push(p : Point):Int {
		resetCache();
		return data.push(toImmutable( p ));
	}

	/**
	  * Remove and return the last Point in [this] VertexArray
	  */
	public function pop():Null<Point> {
		resetCache();
		return data.pop();
	}

	/**
	  * Add a new Point to the beginning of [this] VertexArray
	  */
	public function unshift(p : Point):Int {
		resetCache();
		data.unshift(toImmutable( p ));
		return length;
	}

	/**
	  * Remove and return the first Point in [this] VertexArray
	  */
	public function shift():Null<Point> {
		resetCache();
		return data.shift();
	}

	/**
	  * Create and return a copy of [this]
	  */
	public function clone():VertexArray {
		return new VertexArray( data );
	}

	/**
	  * Calculate the Line segments implied by these vertices
	  */
	public function calculateLines(close:Bool = false):Array<Line> {
		var cached:Null<Array<Line>> = (close ? _lines.right : _lines.left);
		/* if the Lines are already saved */
		if (cached != null) {
			return cached;
		}

		/* otherwise, calculate them */
		else {
			var lines:Array<Line> = new Array();
			var i:Int = 0;
			var last:Null<Point> = null;
			while (i < length) {
				var start = data[i];
				if (last == null) {
					last = start;
				}
				else {
					lines.push(new Line(last, start));
					last = start;
				}
				i++;
			}
			if (close) {
				lines.push(new Line(data.last(), data[0]));
				_lines.right = lines;
			}
			else {
				_lines.left = lines;
			}

			return lines;
		}
	}

	/**
	  * Get a Stack of Lines
	  */
	public inline function lineStack(close:Bool = false):Stack<Line> {
		return new Stack<Line>(calculateLines(close));
	}

	/**
	  * Get a Stack of Points
	  */
	private function pointStack():Stack<Point> {
		var rdat = data.copy();
		rdat.reverse();
		return new Stack<Point>( rdat );
	}

	/**
	  * Simplify [this] VertexArray
	  */
	public function simplify(threshold:Int = 2):Void {
		var s = pointStack();
		var ndata:Array<Point> = new Array();
		var pass = ndata.push.bind(_);

		while (!s.empty) {
			var x = s.pop();
			var y = s.peek();

			if (Math.round(x.distanceFrom(y)) < threshold) {
				s.add( y );
			}
			else {
				pass( x );
			}
		}

		if (data.length != ndata.length) {
			data = ndata;
			resetCache();
		}
	}

	/**
	  * Apply [f] to all Points in [this]
	  */
	public function each(f:Point -> Void):Void {
		var points = pointStack();
		while (!points.empty) {
			var ip = points.peek();
			var p = toMutable(points.pop());
			f( p );
			cast(ip, ImmutablePoint).write( p );
		}
		resetCache();
	}

	/**
	  * Apply the given Matrix to [this] VertexArray
	  */
	public function apply(m : Matrix):Void {
		each( m.transformPoint );
	}

	/**
	  * Create a new VertexArray by applying [f] to all Points in [this] one
	  */
	public function map(f : Point->Point):VertexArray {
		return new VertexArray(data.map( f ));
	}

	/**
	  * Calculate a Rectangle that all Points in [this] VertexArray fall inside
	  */
	public function getContainingRect():Rectangle {
		if (_rect == null) {
			var xr = data.minmax(function(p) return p.x);
			var yr = data.minmax(function(p) return p.y);
			_rect = new Rectangle(xr.min, yr.min, xr.size, yr.size);
		}
		return _rect;
	}

/* === Computed Instance Fields === */

	/* the length of [this] Verts */
	public var length(get, never):Int;
	private inline function get_length():Int return data.length;

	/* the Line segments implied by [this] VertexArray */
	public var lines(get, never):Array<Line>;
	private inline function get_lines() return calculateLines(true);

	/* a Rectangle that contains all Points in [this] VertexArray */
	public var rect(get, never):Rectangle;
	private inline function get_rect() return getContainingRect();

	/* the first Point in [this] Array */
	public var first(get, never):Point;
	private inline function get_first():Point return get(0);

	/* the last Point in [this] Array */
	public var last(get, never):Point;
	private inline function get_last():Point return get(length - 1);

/* === Instance Fields === */

	/* the list of Point objects */
	private var data : Array<Point>;

	/* the cached list of Lines */
	private var _lines : Pair<Null<Array<Line>>, Null<Array<Line>>>;

	/* the cached rect */
	private var _rect : Null<Rectangle>;
}

/**
  * Point-Iterator for VertexArrays
  */
class VerticeIterator {
	public function new(va : VertexArray):Void {
		array = va;
		iter = new IntIterator(0, array.length);
	}

/* === Instance Methods === */

	public function hasNext():Bool {
		return iter.hasNext();
	}

	public function next():Point {
		return array.get(iter.next());
	}

/* === Instance Fields === */

	private var array : VertexArray;
	private var iter : IntIterator;
}

/**
  * underlying type for Point that disallows the changing of Point's fields
  */
class ImmutablePoint extends TPoint {
	override private function set_x(v:Float):Float return v;
	override private function set_y(v:Float):Float return v;
	override private function set_z(v:Float):Float return v;

	public function write(p : Point):Void {
		_x = p.x;
		_y = p.y;
		_z = p.z;
	}
}
