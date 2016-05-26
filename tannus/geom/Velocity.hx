package tannus.geom;

import tannus.geom.Angle;
import tannus.geom.Point;
import tannus.geom.Line;

import tannus.math.TMath;

import tannus.ds.TwoTuple;

@:forward
abstract Velocity (CVelocity) from CVelocity to CVelocity {
	/* Constructor Function */
	public inline function new(speed:Float, angle:Angle):Void {
		this = new CVelocity(speed, angle);
	}

/* === Instance Methods === */


	@:op( !A )
	public inline function invert():Velocity return this.invert();

	@:op(A + B)
	public inline function plus(other : Velocity):Velocity return this.plus( other );

	@:op(A - B)
	public inline function minus(other : Velocity):Velocity return this.minus( other );

	@:to
	public inline function toPoint():Point return this.vector;

	@:from
	public static inline function fromPoint(p : Point):Velocity return CVelocity.fromPoint( p );
}

class CVelocity {
	/* Constructor Function */
	public function new(speed:Float, angle:Angle):Void {
		this.speed = speed;
		this.angle = angle;
	}

/* === Instance Methods === */

	/**
	  * Reassign [speed, angle] as [x-velocity, y-velocity]
	  */
	private function setVector(vx:Float, vy:Float):Void {
		var e:Point = new Point(vx, vy);
		var l:Line = new Line(new Point(), e);

		speed = l.length;
		angle = new Angle(TMath.angleBetween(0.0, 0.0, e.x, e.y));
	}

	/**
	  * Create and return a clone of [this] Velocity
	  */
	public function clone():Velocity {
		return new Velocity(speed, angle);
	}

	/**
	  * Invert [this] Velocity
	  */
	public function invert():Velocity {
		return cast fromVector(-x, -y);
	}

	/**
	  * Obtain the sum of [this] Velocity and another
	  */
	public function plus(other : Velocity):Velocity {
		return fromPoint(vector + other.vector);
	}

	/**
	  * Obtain the difference between [this] Velocity and another
	  */
	public function minus(other : Velocity):Velocity {
		return fromPoint(vector - other.vector);
	}

	/**
	  * perform linear interpolation on [this] Velocity
	  */
	public function lerp(other:Velocity, weight:Float):Velocity {
		var vec = vector.lerp(other.vector, weight);
		return fromPoint( vec );
	}

/* === Computed Instance Fields === */

	/* Movement along the 'x' axis */
	public var x(get, set):Float;
	private inline function get_x():Float {
		return (Math.cos(angle.radians) * speed);
	}
	private function set_x(nx : Float):Float {
		setVector(nx, y);
		return nx;
	}

	/* Movement along the 'y' axis */
	public var y(get, set):Float;
	private inline function get_y():Float {
		return (Math.sin(angle.radians) * speed);
	}
	private function set_y(ny : Float):Float {
		setVector(x, ny);
		return ny;
	}

	/* Movement, represented as a Point */
	public var vector(get, set):Point;
	private function get_vector():Point {
		return new Point(x, y);
	}
	private function set_vector(v : Point):Point {
		setVector(v.x, v.y);
		return vector;
	}

/* === Instance Fields === */

	public var speed : Float;
	public var angle : Angle;

/* === Static Methods === */

	/**
	  * Create Velocity from Point
	  */
	public static function fromVector(x:Float, y:Float):CVelocity {
		return fromPoint(new Point(x, y));
	}

	/**
	  * Create Velocity from Point
	  */
	public static function fromPoint(p : Point):Velocity {
		var vel = new Velocity(0, 0);
		vel.vector = p;
		return vel;
	}
}
