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

class Bezier<T:Float> {
    public function new(start:Point<T>, ctrl1:Point<T>, ctrl2:Point<T>, end:Point<T>):Void {
        this.start = start;
        this.ctrl1 = ctrl1;
        this.ctrl2 = ctrl2;
        this.end = end;
    }

/* === Instance Methods === */

    public inline function clone():Bezier<T> {
        return new Bezier(start.clone(), ctrl1.clone(), ctrl2.clone(), end.clone());
    }

    public inline function equals(other: Bezier<T>):Bool {
        return (
            (start.equals( other.start )) &&
            ctrl1.equals( other.ctrl1 ) &&
            ctrl2.equals( other.ctrl2 ) &&
            end.equals( other.end )
        );
    }

    public function flip():Void {
        //- handle 'x' axes
		var temp:T = start.x;
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
	public function getPointX(t : Float):Float {
		//- start and end are special cases
		if (t == 0) {
			return start.x;
		} 
		else if (t == 1) {
			return end.x;
		}

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
	public function getPointY(t : Float):Float {
		//- start and end are special cases
		if (t == 0) {
			return start.y;
		} 
		else if (t == 1) {
			return end.y;
		}

		var iy0 = lerp(start.y, ctrl1.y, t);
		var iy1 = lerp(ctrl1.y, ctrl2.y, t);
		var iy2 = lerp(ctrl2.y, end.y, t);

		iy0 = lerp(iy0, iy1, t);
		iy1 = lerp(iy1, iy2, t);

		return lerp(iy0, iy1, t);
	}

	public inline function getPoint(t: Float):Point<Float> {
	    return new Point(getPointX( t ), getPointY( t ));
	}

	public function getPoints(precision: Int):Array<Point<Float>> {
	    var results = [];
	    var i:Int = 0;
	    while (i < precision) {
	        results.push(getPoint(i / precision));
	        i++;
	    }
	    return results;
	}

/* === Instance Fields === */

    public var start:Point<T>;
    public var end:Point<T>;
    public var ctrl1:Point<T>;
    public var ctrl2:Point<T>;
}
