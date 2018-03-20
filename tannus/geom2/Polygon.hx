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

class Polygon <T:Float> {
    /* Constructor Function */
    public function new(?data: Iterable<Point<T>>):Void {
        points = new Array();
        _origin = null;

        if (data != null) {
            var i = data.iterator();
            if (i.hasNext()) {
                var first = i.next();
                start(first.x, first.y);
                while (i.hasNext()) {
                    addPoint(i.next());
                }
            }
        }
    }

/* === Instance Methods === */

    public inline function start(x:T, y:T):Void {
        if (origin == null) {
            origin = new Point(x, y);
        }
    }

    public inline function add(x:T, y:T):Void {
        points.push(new Point(x, y));
    }

    public inline function addPoint(p: Point<T>):Void {
        points.push( p );
    }

    public inline function close():Void {
        //
    }

    public function clone():Polygon<T> {
        var copy = new Polygon();
        copy.start(_origin.x, _origin.y);
        for (p in points) {
            copy.addPoint(p.clone());
        }
        return copy;
    }

/* === Instance Fields === */

    private var points: Array<Point<T>>;
    private var _origin: Null<Point<T>>;
}
