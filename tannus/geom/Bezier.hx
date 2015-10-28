package tannus.geom;

import tannus.math.TMath;
import tannus.math.Percent;

import tannus.geom.Point;

class Bezier {
	/* Constructor Function */
	public function new(start:Point, ctrl1:Point, ctrl2:Point, end:Point):Void {
		this.start = start;
		this.ctrl1 = ctrl1;
		this.ctrl2 = ctrl2;
		this.end = end;
	}

/* === Instance Methods === */

	/**
	  * Create and return a clone of [this] Bezier
	  */
	public inline function clone():Bezier {
		return new Bezier(start, ctrl1, ctrl2, end);
	}

	/**
	  * Test whether [other] Bezier is the same as [this] one
	  */
	public function equals(other : Bezier):Bool {
		return (start == other.start && ctrl1 == other.ctrl1 && ctrl2 == other.ctrl2 && end == other.end);
	}

	/**
	  * Modify [this] Bezier in place to progress in the opposite direction
	  */
	public function flip():Void {
		//- handle 'x' axes
		var temp:Float = start.x;
		start.x = end.x;
		end.x = temp;

		temp = ctrl1.x;
		ctrl1.x = ctrl2.x;
		ctrl2.x = temp;

		//- handle 'y' axes
		temp = start.y;
		start.y = end.y;
		end.y = temp;

		temp = ctrl1.y;
		ctrl1.y = ctrl2.y;
		ctrl2.y = temp;
	}

	/**
	  * Calculates the 'x' position of the curve at a given degree of completion
	  */
	public function getPointX(pt : Percent):Float {
		var t:Float = pt.of( 1 );

		//- start and end are special cases
		if (t == 0) {
			return start.x;
		} else if (t == 1) {
			return end.x;
		}

		var lerp = TMath.lerp.bind(_, _, _);
		
		var ix0 = lerp(start.x, ctrl1.x, t);
		var ix1 = lerp(ctrl1.x, ctrl2.x, t);
		var ix2 = lerp(ctrl2.x, end.x, t);

		ix0 = lerp(ix0, ix1, t);
		ix1 = lerp(ix1, ix2, t);

		return lerp(ix0, ix1, t);
	}

	/**
	  * Calculates the 'y' position of the curve at a given degree of completion
	  */
	public function getPointY(pt : Percent):Float {
		var t:Float = pt.of( 1 );

		//- start and end are special cases
		if (t == 0) {
			return start.y;
		} else if (t == 1) {
			return end.y;
		}

		var lerp = TMath.lerp.bind(_, _, _);
		
		var iy0 = lerp(start.y, ctrl1.y, t);
		var iy1 = lerp(ctrl1.y, ctrl2.y, t);
		var iy2 = lerp(ctrl2.y, end.y, t);

		iy0 = lerp(iy0, iy1, t);
		iy1 = lerp(iy1, iy2, t);

		return lerp(iy0, iy1, t);
	}

	/**
	  * Calculates the position of the curve at a given point of completion
	  */
	public inline function getPoint(t : Percent):Point {
		return new Point(getPointX(t), getPointY(t));
	}

	/**
	  * Creates and returns a list of all Points along [this] Bezier
	  */
	public inline function getPoints(?prec:Int):Array<Point> {
		var results:Array<Point> = new Array();
		var precision:Int = (prec != null ? prec : PRECISION);
		var i:Int = 0;

		while (i < precision) {
			var pt:Point = getPoint((i / precision) * 100);
			results.push( pt );
			i++;
		}

		return results;
	}

/* === Instance Fields === */

	//- The starting position of [this] Bezier
	public var start:Point;

	//- The first control point of [this] Bezier
	public var ctrl1:Point;

	//- The second control point of [this] Bezier
	public var ctrl2:Point;
	
	//- The ending position of [this] Bezier
	public var end:Point;

/* === Class Methods === */

	public static var PRECISION:Int = 100;
}
