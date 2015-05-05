package tannus.geom;

import tannus.geom.Angle;
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
	public var x(get, never):Float;
	private inline function get_x():Float {
		return (Math.sin(angle.degrees) * speed);
	}

	/* Movement along the 'y' axis */
	public var y(get, never):Float;
	private inline function get_y():Float {
		return (Math.cos(angle.degrees) * speed);
	}
}
