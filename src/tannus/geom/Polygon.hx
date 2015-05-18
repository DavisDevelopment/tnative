package tannus.geom;

import tannus.geom.Point;
import tannus.geom.Line;
import tannus.geom.Shape;
import tannus.geom.Vertices;

using Lambda;
class Polygon implements Shape {
	/* Constructor Function */
	public function new():Void {
		vertices = new Vertices();
	}

/* === Instance Methods === */

	/**
	  * Add a Point to [this] Polygon
	  */
	public function addPoint(pt : Point):Void {
		vertices.add( pt );
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
		c.vertices = vertices.clone();
		return c;
	}

	/**
	  * Get the lines which make up [this] Polygon
	  */
	public function getLines(?close:Bool = false):Array<Line> {
		return vertices.calculateLines(close);
	}

	/**
	  * Obtain [this] Shape's vertices
	  */
	public function getVertices():Vertices {
		return vertices;
	}

/* === Instance Fields === */

	/* The Points associated with [this] Polygon */
	public var vertices:Vertices;
}
