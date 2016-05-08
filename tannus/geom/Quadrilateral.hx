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

class Quadrilateral implements Shape {
	/* Constructor Function */
	public function new(?a:Point, ?b:Point, ?c:Point, ?d:Point):Void {
		data = new Array();
		this.a = new Point();
		this.b = new Point();
		this.c = new Point();
		this.d = new Point();
		if (a != null) this.a.copyFrom( a );
		if (b != null) this.b.copyFrom( b );
		if (c != null) this.c.copyFrom( c );
		if (d != null) this.d.copyFrom( d );
	}

/* === Instance Methods === */

	/**
	  * Get a VertexArray from [this] Quadrilateral
	  */
	public function getVertices(?precision : Int):Vertices {
		return new Vertices( data );
	}

	/**
	  * Get the containing Rectangle around [this] Quadrilateral
	  */
	public inline function getContainingRect():Rectangle {
		return getVertices().getContainingRect();
	}

/* === Computed Instance Fields === */

	/* the first Point in [this] Quadrilateral */
	public var a(get, set):Point;
	private function get_a():Point return data[0];
	private function set_a(v : Point):Point return (data[0] = v);

	/* the second Point in [this] Quadrilateral */
	public var b(get, set):Point;
	private function get_b():Point return data[1];
	private function set_b(v : Point):Point return (data[1] = v);

	/* the third Point in [this] Quadrilateral */
	public var c(get, set):Point;
	private function get_c():Point return data[2];
	private function set_c(v : Point):Point return (data[2] = v);

	/* the fourth Point in [this] Quadrilateral */
	public var d(get, set):Point;
	private function get_d():Point return data[3];
	private function set_d(v : Point):Point return (data[3] = v);

/* === Instance Fields === */

	private var data : Array<Point>;
}
