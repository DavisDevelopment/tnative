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

class Arc <T:Float> {
    public function new(center:Point<T>, radius:Float, start:Angle, end:Angle, counterClockwise:Bool=false):Void {
        this.center = center;
        this.radius = radius;
        this.start_angle = start;
        this.end_angle = end;
        this.clockwise = !counterClockwise;
    }

/* === Instance Methods === */

    public inline function clone():Arc<T> {
        return new Arc(center, radius, start_angle, end_angle, !clockwise);
    }

    public function getPoint(n: Float):Point<Float> {
        var angle:Angle = new Angle(start_angle.getDegrees().lerp(end_angle.getDegrees(), n));
        return new Point((center.x + angle.getX() * radius), (center.y + angle.getY() * radius));
    }

    public function getPoints(precision: Int):Array<Point<Float>> {
        var interval:Float = precision.reciprocal();
        var results:Array<Point<Float>> = new Array();
        var i:Float = 0.0;
        while (i < 1.0) {
            results.push(getPoint( i ));

            i += interval;
        }
        return results;
    }

/* === Computed Instance Fields === */

    public var x(get, never):T;
    private inline function get_x() return center.x;
    
    public var y(get, never):T;
    private inline function get_y() return center.y;

/* === Instance Fields === */

    public var center: Point<T>;
    public var radius: Float;
    public var start_angle: Angle;
    public var end_angle: Angle;
    public var clockwise: Bool;
}
