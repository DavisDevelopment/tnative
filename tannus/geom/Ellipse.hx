package tannus.geom;

import tannus.geom.Point;
import tannus.geom.Rectangle;
import tannus.geom.Line;
import tannus.geom.Bezier;
import tannus.math.TMath;
import tannus.geom.Shape;
import tannus.geom.Vertices;

class Ellipse implements Shape {
	/* Constructor Function */
	public function new(x:Float, y:Float, w:Float, h:Float):Void {
		pos = new Point(x, y);
		width = w;
		height = h;
	}

/* === Instance Methods === */

	/**
	  * Creates and returns the two Bezier Curves which make up [this] Ellipse
	  */
	public function calculateCurves():Array<Bezier> {
		var center:Point = rect.center;
		var x:Float = pos.x;		var y:Float = pos.y;
		var aX:Float = x;
		var aY:Float = y;
		var hB:Float = (width / 2) * TMath.KAPPA;
		var vB:Float = (height / 2) * TMath.KAPPA;
		var eX:Float = (x + width);
		var eY:Float = (y + height);
		var mX:Float = (x + width/2);
		var mY:Float = (y + height/2);
		
		var p = (function(?x:Float, ?y:Float) return new Point(x, y));
				
		var one:Bezier = new Bezier(p(aX, mY), p(aX, mY - vB), p(mX - hB, aY), p(mX, aY));
		var two:Bezier = new Bezier(p(mX, aY), p(mX + hB, aY), p(eX, mY - vB), p(eX, mY));
		var three:Bezier = new Bezier(p(eX, mY), p(eX, mY + vB), p(mX + hB, eY), p(mX, eY));
		var four:Bezier = new Bezier(p(mX, eY), p(mX - hB, eY), p(aX, mY + vB), p(aX, mY));

		return [one, two, three, four];
	}

	/**
	  * Creates and returns a list of all Points along the circumference of [this] Ellipse
	  */
	public function getPoints():Array<Point> {
		var curves = calculateCurves();
		var points:Array<Point> = new Array();

		for (curve in curves) {
			points = points.concat(curve.getPoints());
		}
		
		return points;
	}

	public function getVertices() {
		return new Vertices(getPoints());
	}

/* === Instance Fields === */

	//- The position of [this] Ellipse
	public var pos:Point;

	//- The width of [this] Ellipse
	public var width:Float;

	//- The height of [this] Ellipse
	public var height:Float;

/* === Computed Fields === */

	/**
	  * The rectangle of [this] Ellipse
	  */
	public var rect(get, set):Rectangle;
	private inline function get_rect():Rectangle {
		return new Rectangle(pos.x, pos.y, width, height);
	}
	private inline function set_rect(nr : Rectangle):Rectangle {
		pos.x = nr.x;
		pos.y = nr.y;
		width = nr.width;
		height = nr.height;
		return rect;
	}

	/* the center of [this] Ellipse */
	public var center(get, never):Point;
	private inline function get_center():Point {
		return rect.center;
	}
}
