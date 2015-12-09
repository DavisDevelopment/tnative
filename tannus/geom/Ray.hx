package tannus.geom;

import tannus.geom.*;
import tannus.math.TMath;

using tannus.math.TMath;

class Ray {
	/* Constructor Function */
	public function new(start:Point, angl:Angle):Void {
		x = start.ix;
		y = start.iy;
		angle = angl;
	}

/* === Instance Methods === */

	/**
	  * Create a RayWalker to walk [this] Ray
	  */
	public function walk():RayWalker {
		return new RayWalker( this );
	}

/* === Instance Fields === */

	public var x : Int;
	public var y : Int;
	public var angle : Angle;
}

/**
  * Class for walking (iterating) a Ray
  */
class RayWalker {
	/* Constructor Function */
	public function new(r : Ray):Void {
		ray = r;
		pos = new Point(ray.x, ray.y);
		vel = new Velocity(1, ray.angle);
	}

/* === Instance Methods === */

	/**
	  * Get the next Point along [ray]
	  */
	public function step():Point {
		var result:Point = pos.clone();


		pos += offset;
		pos.clamp();

		return result;
	}

	/**
	  * Iterator.hasNext method
	  */
	public function hasNext():Bool {
		return (offset != [0, 0]);
	}

	/**
	  * Iterator.next method
	  */
	public function next():Point {
		return step();
	}

/* === Computed Instance Fields === */

	/* the offset vector */
	private var offset(get, never):Point;
	private function get_offset():Point {
		var o = vel.vector;
		o.clamp();
		return o;
	}

/* === Instance Fields === */

	public var ray : Ray;
	public var pos : Point;
	private var vel : Velocity;
}
