package tannus.geom2;

import tannus.ds.DataView;

import tannus.geom2.Angle;

import Std.*;
import tannus.math.TMath.*;

using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;

@:expose
class Velocity {
	/* Constructor Function */
	public function new(speed:Float, angle:Angle):Void {
		this.speed = speed;
		this.angle = angle;
	}

/* === Instance Methods === */

	/**
	  * create and return a clone of [this]
	  */
	public inline function clone():Velocity {
		return new Velocity(speed, angle);
	}

	/**
	  * set the velocity along the x and y axes separately
	  */
	public inline function setVector(vx:Float, vy:Float):Velocity {
		speed = TMath.distance(0, 0, vx, vy);
		angle = new Angle(TMath.angleBetween(0, 0, vx, vy));
		return this;
	}

	/**
	  * invert [this] vector
	  */
	public inline function invert():Void {
		setVector(-x, -y);
	}

	/**
	  * apply [this] movement vector to the given Point
	  */
	public function apply(point : Point<Float>):Void {
		point.x += x;
		point.y += y;
	}

/* === Computed Instance Fields === */

	public var x(get, set):Float;
	private inline function get_x():Float return (Math.cos(angle.getRadians()) * speed);
	private function set_x(v : Float):Float {
		setVector(v, y);
		return v;
	}
	
	public var y(get, set):Float;
	private inline function get_y():Float return (Math.sin(angle.getRadians()) * speed);
	private function set_y(v : Float):Float {
		setVector(x, v);
		return v;
	}

	public var vector(get, set):Point<Float>;
	private inline function get_vector():Point<Float> return new Point(x, y);
	private function set_vector(v : Point<Float>):Point<Float> {
		setVector(v.x, v.y);
		return vector;
	}

/* === Instance Fields === */

	public var angle : Angle;
	public var speed : Float;

/* === Static Methods === */

	public static inline function fromVector(x:Float, y:Float):Velocity {
		return (new Velocity(0, new Angle(0)).setVector(x, y));
	}
	public static inline function fromPoint(p : Point<Float>):Velocity {
		return fromVector(p.x, p.y);
	}
}
