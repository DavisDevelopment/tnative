package tannus.geom2;

import tannus.ds.*;

//import Math.*;
import tannus.math.TMath.*;
import tannus.ds.SortingTools.compresolve;

import haxe.Serializer;
import haxe.Unserializer;

using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;

class Ellipse <T:Float> {
    /* Constructor Function */
    public function new(?x:T, ?y:T, ?w:T, ?h:T):Void {
        if (x == null) x = untyped 0;
        if (y == null) y = untyped 0;
        if (w == null) w = untyped 0;
        if (h == null) h = untyped 0;

        pos = new Point(x, y);
        width = w;
        height = h;
    }

/* === Instance Methods === */

    /**
	  * Creates and returns the two Bezier Curves which make up [this] Ellipse
	  */
	public function calculateCurves():Array<Bezier<Float>> {
	    inline function pt(x:Float, y:Float):Point<Float> return new Point(x, y);
	    inline function bz(a:Point<Float>, b:Point<Float>, c:Point<Float>, d:Point<Float>):Bezier<Float> return new Bezier(a, b, c, d);
	    inline function half(n: Float):Float return (n / 2);

		//var center:Point<Float> = getRect().center;
		var x:Float = (pos.x + 0.0);
		var y:Float = (pos.y + 0.0);
		var aX:Float = x;
		var aY:Float = y;
		var hB:Float = (half(width) * KAPPA);
		var vB:Float = (half(height) * KAPPA);
		var eX:Float = (x + width);
		var eY:Float = (y + height);
		var mX:Float = (x + half(width));
		var mY:Float = (y + half(height));
		
		return [
		    bz(pt(aX, mY), pt(aX, mY - vB), pt(mX - hB, aY), pt(mX, aY)),
		    bz(pt(mX, aY), pt(mX + hB, aY), pt(eX, mY - vB), pt(eX, mY)),
		    bz(pt(eX, mY), pt(eX, mY + vB), pt(mX + hB, eY), pt(mX, eY)),
		    bz(pt(mX, eY), pt(mX - hB, eY), pt(aX, mY + vB), pt(aX, mY))
		];
	}

	/**
	  * get a Point along [this] Ellipse
	  */
	public function getPoint(t: Float):Point<Float> {
	    var curves = calculateCurves();
	    var index : Int;
	    if (t < (1 / 4)) {
	        index = 0;
	    }
        else if (t < (1 / 2)) {
            index = 1;
        }
        else if (t < (3 / 4)) {
            index = 2;
        }
        else {
            index = 3;
        }

        t /= (1 / 4);
        var curve:Bezier<Float> = curves[index];
        return curve.getPoint( t );
	}

	/**
	  * get all points along [this] Ellipse
	  */
	public function getPoints(precision: Int):Array<Point<Float>> {
	    var curvePrecision:Float = (precision / 4);
	    var curves:Array<Bezier<Float>> = calculateCurves();
	    return [
	        curves[0].getPoints(floor(curvePrecision)),
	        curves[1].getPoints(ceil(curvePrecision)),
	        curves[2].getPoints(floor(curvePrecision)),
	        curves[3].getPoints(ceil(curvePrecision))
	    ].flatten();
	}

	/**
	  * get [this]'s Rect<T>
	  */
	public inline function getRect():Rect<T> {
	    return new Rect(pos.x, pos.y, width, height);
	}

/* === Instance Fields === */

    public var pos: Point<T>;
    public var width: T;
    public var height: T;
}
