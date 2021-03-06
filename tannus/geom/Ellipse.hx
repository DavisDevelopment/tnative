package tannus.geom;

import tannus.geom.Point;
import tannus.geom.Rectangle;
import tannus.geom.Line;
import tannus.geom.Bezier;
import tannus.math.TMath;
import tannus.geom.Shape;
import tannus.geom.Vertices;

import Math.*;
import tannus.math.TMath.*;

class Ellipse implements Shape implements PathComponent {
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
	public function getPoints(?curvePrecision : Int):Array<Point> {
		var curves = calculateCurves();
		var points:Array<Point> = new Array();

		for (curve in curves) {
			points = points.concat(curve.getPoints( curvePrecision ));
		}
		
		return points;
	}

	/**
	  * get [this] Ellipse's VertexArray
	  */
	public function getVertices(?precision : Int):Vertices {
		return new Vertices(getPoints( precision ));
	}

	/**
	  * add [this] Ellipse to a Path
	  */
	public function addToPath(path : Path):Void {
		var ep = new Path();
		var curves = calculateCurves();
		for (b in curves) {
			ep.addBezier( b );
		}
		path.addPath( ep );
	}

	/**
	  * check whether the given point is inside [this] Ellipse
	  */
	public function containsPoint(p : Point):Bool {
		var m = center;
		var dx = abs(p.x - m.x);
		var dy = abs(p.y - m.y);
		return ((((dx * dx) / (width * width)) + ((dy * dy) / (height * height))) <= 1);
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
	public var center(get, set):Point;
	private inline function get_center():Point return Point.linked(centerX, centerY);
	private function set_center(v : Point):Point {
		centerX = v.x;
		centerY = v.y;
		return center;
	}

	public var x(get, set):Float;
	private function get_x():Float {
		return pos.x;
	}
	private function set_x(v : Float):Float {
		return (pos.x = v);
	}

	public var y(get, set):Float;
	private function get_y():Float {
		return pos.y;
	}
	private function set_y(v : Float):Float {
		return (pos.y = v);
	}

	public var centerX(get, set):Float;
	private function get_centerX():Float {
		return (x + width / 2);
	}
	private function set_centerX(v : Float):Float {
		return x = v - width / 2;
	}

	public var centerY(get, set):Float;
	private function get_centerY():Float {
		return (y + height / 2);
	}
	private function set_centerY(v : Float):Float {
		return y = v - height / 2;
	}


/* === Static Methods === */

	/**
	  * Create an Ellipse from a Rectangle
	  */
	public static inline function fromRectangle(r : Rectangle):Ellipse {
		return new Ellipse(r.x, r.y, r.w, r.h);
	}
}
