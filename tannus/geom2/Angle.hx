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

class Angle {
    public inline function new(v: Float):Void {
        this.v = v;
    }

/* === Instance Methods === */

    public inline function getDegrees():Float return v;
    public inline function getRadians():Float return (v * PI / 180);
    public inline function getX():Float return cos(getRadians());
    public inline function getY():Float return sin(getRadians());

	public function toString():String {
		return (v + '\u00B0');
	}

	public function invert():Angle return new Angle( -v );
	public function compliment():Angle return new Angle(360 - v);

	public static function fromRadians(radians: Float):Angle return new Angle(toDegrees( radians ));

/* === Instance Fields === */

    private var v: Float;
}
