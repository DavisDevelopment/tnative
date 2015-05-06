package tannus.geom;

import tannus.geom.Angle;
import tannus.geom.Point;
import tannus.geom.Line;

import tannus.math.TMath;

import tannus.ds.TwoTuple;

/**
  * Abstract Class to represent the velocity of an entity
  */
abstract Velocity (TwoTuple<Float, Angle>) {
	/* Constructor Function */
	public inline function new(speed:Float, angle:Angle):Void {
		this = new TwoTuple(speed, angle);
	}

/* === Instance Methods === */

	/**
	  * Reassign [speed, angle] as [x-velocity, y-velocity]
	  */
	private function setVector(vx:Float, vy:Float):Void {
		var e:Point = new Point(vx, vy);
		var l:Line = new Line([0, 0], e);

		speed = l.length;
		angle = TMath.angleBetween(0.0, 0.0, e.x, e.y);
	}

	/**
	  * Create and return a copy of [this] Velocity
	  */
	public inline function clone():Velocity {
		return new Velocity(speed, angle);
	}

/* === Instance Fields === */

	/* Speed of Movement */
	public var speed(get, set):Float;
	private inline function get_speed() return this.one;
	private inline function set_speed(ns) return (this.one = ns);

	/* Angle of Movement */
	public var angle(get, set):Angle;
	private inline function get_angle() return this.two;
	private inline function set_angle(ns) return (this.two = ns);

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

	/* Movement represented as a Point */
	public var vector(get, set):Point;
	private inline function get_vector() return new Point(x, y);
	private inline function set_vector(nv : Point):Point {
		setVector(nv.x, nv.y);
		return new Point(x, y);
	}
}
