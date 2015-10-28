package tannus.geom;

import tannus.geom.Point;
import tannus.geom.Line;
import tannus.geom.Vertices;
import tannus.geom.Shape;
import tannus.geom.HitMask;

import tannus.ds.IntRange;
import tannus.math.TMath in N;

class Path {
	/* Constructor Function */
	public function new():Void {
		verts = new Array();
	}

/* === Instance Methods === */

	/* Add a Shape onto [this] Path */
	public function add(shape : Shape):Void {
		verts.push(shape.getVertices());
	}

	/**
	  * Do Stuff
	  */
	public function getLines():Array<Line> {
		var all_lines:Array<Line> = new Array();

		for (v in verts) {
			all_lines = all_lines.concat(v.toLines());
		}

		return all_lines;
	}

	/**
	  * Get Points
	  */
	public function getPoints():Array<Point> {
		var lines = getLines();
		var points:Array<Point> = new Array();

		for (line in lines) {
			points = points.concat(line.getVertices().toPoints());
		}

		for (p in points) p.clamp();
		return points;
	}

	/**
	  * Map the Points into something useful
	  */
	public function getHitmask():HitMask {
		var reg:Map<Int, Array<Int>> = new Map();
		var points = getPoints();

		for (p in points) {
			var x:Int = p.ix;
			var y:Int = p.iy;
			
			if (reg[y] == null)
				reg[y] = new Array();
			reg[y].push(x);
		}

		var ranges:Map<Int, IntRange> = new Map();
		var keys:Array<Int> = [for (y in reg.keys()) y];
		var yrange:IntRange = (cast N.range(keys));
		var xrange:IntRange = new IntRange(0,1);

		for (y in keys) {
			var xs:Array<Int> = reg[y];
			var xr:IntRange;

			if (xs.length == 1) {
				null;
			}
			else {
				if (xs.length == 2) {
					xr = new IntRange(xs[0], xs[1]);
				}
				else {
					xr = cast N.range( xs );
				}
				xrange.min = N.min(xrange.min, xr.min);
				xrange.max = N.max(xrange.max, xr.max);
				ranges[y] = xr;
			}
		}

		var crect:Rectangle = new Rectangle(xrange.min, yrange.min, (xrange.max - xrange.min), (yrange.max - yrange.min));
		return new HitMask(crect, ranges);
	}

/* === Instance Fields === */
	public var verts:Array<Vertices>;
}
