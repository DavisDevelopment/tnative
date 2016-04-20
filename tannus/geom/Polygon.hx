package tannus.geom;

import tannus.geom.Point;
import tannus.geom.Line;
import tannus.geom.Shape;
import tannus.geom.Vertices;

using Lambda;
class Polygon implements Shape {
	/* Constructor Function */
	public function new():Void {
		points = new Array();
	}

/* === Instance Methods === */

	/**
	  * Add a Point to [this] Polygon
	  */
	public function addPoint(pt : Point):Point {
		points.push( pt );
		return pt;
	}

	/**
	  * Alias to [addPoint]
	  */
	public inline function pt(x:Float, y:Float):Void {
		addPoint([x, y]);
	}

	/**
	  * Create and return a clone of [this] Polygon
	  */
	public function clone():Polygon {
		var c = new Polygon();
		c.points = [for (p in points) p.clone()];
		return c;
	}

	/**
	  * Get the lines which make up [this] Polygon
	  */
	public function getLines(?close:Bool = false):Array<Line> {
		return vertices.calculateLines( close );
	}

	/**
	  * Obtain [this] Shape's vertices
	  */
	public function getVertices(?precision:Int):Vertices {
		return vertices;
	}

/* === Computed Instance Fields === */

	public var vertices(get, never):Vertices;
	private inline function get_vertices():Vertices return new Vertices( points );

/* === Instance Fields === */

	/* The Points associated with [this] Polygon */
	public var points : Array<Point>;
}
