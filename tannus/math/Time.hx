package tannus.math;

import tannus.ds.*;

import Std.is;
import Std.int;
import Slambda.fn;
import tannus.math.TMath.*;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;
using tannus.FunctionTools;
using tannus.math.TMath;

@:forward
abstract Time (CTime) from CTime to CTime {
    /* Constructor Function */
    public inline function new(sec:Float=0.0, m:Int=0, h:Int=0, d:Int=0):Void {
        this = new CTime(sec, m, h, d);
    }

/* === Instance Methods === */

    @:op(A + B)
    public inline function plusTime(x: Time):Time return this.plusTime( x );

    @:op(A - B)
    public inline function minusTime(x: Time):Time return this.minusTime( x );

    @:op(A += B)
    public inline function iplusTime(x: Time):Time return this.iplusTime( x );

    @:op(A -= B)
    public inline function iminusTime(x: Time):Time return this.iminusTime( x );

    @:op(A * B)
    public inline function multipliedBy(x: Float):Time return this.multipliedBy( x );

    @:op(A / B)
    public inline function dividedBy(x: Float):Time return this.dividedBy( x );

    @:op(A == B)
    public inline function equals(x: Time):Bool return this.equalsTime( x );

/* === Casting Methods === */

    @:from
    public static inline function fromFloat(seconds: Float):Time return CTime.fromSeconds( seconds );

    @:from
    public static inline function fromString(s: String):Time return CTime.fromString( s );

    @:from
    public static inline function fromDate(d: Date):Time return CTime.fromDate( d );

    @:from
    public static inline function fromFloatArray(a : Array<Float>):Time return CTime.fromFloatArray( a );

    @:from
    public static inline function fromAny(x: Dynamic):Time return CTime.fromAny( x );

    @:to
    public inline function toFloat():Float return this.n;

    @:to
    public inline function toString():String return this.toString();

/* === Static Methods === */

    public static inline function isTime(x: Dynamic):Bool return CTime.isTime( x );
}
