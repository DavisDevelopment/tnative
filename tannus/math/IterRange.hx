package tannus.math;

import tannus.ds.tuples.Tup4 as Tuple;
import tannus.ds.FloatRange;
import haxe.Int64;

import Std.*;
//import Math.*;

import haxe.macro.Expr;
import haxe.macro.Context;
//import tannus.math.TMath.*;

using StringTools;
using tannus.ds.StringUtils;
using haxe.macro.ExprTools;
using tannus.macro.MacroTools;
using StringTools;
using tannus.ds.StringUtils;
using tannus.FunctionTools;

class IterRange {
    public function new(x:Int, ?y:Int, ?m:Int) {
        step = 1;
        switch [x, y, m] {
            case [x, null, null]:
                finish = x;
                start = 0;
                if (start > finish && step > 0)
                    step = -step;
            
            case [x, y, null]:
                start = x;
                finish = y;
                if (start > finish && step > 0)
                    step = -step;

            case [x, y, m]:
                start = x;
                finish = y;
                step = m;

            case unex:
                throw 'Unexpected $unex';
        }

        if (start == finish)
            throw '$this has a length of 0';
    }

/* === Methods === */

    public function toString():String {
        return 'range($start, $finish, $step)';
    }

    public function iterator() {
        __i = 0;
        return this;
    }

    @:noCompletion
    function next():Int {
        return (__i != null ? __i += step : (throw 'next() should not be called outside of an iteration'));
    }

    @:noCompletion
    function hasNext():Bool {
        return bd((__i + step) >= finish);
    }

    static inline function bd(d:Int, b:Bool):Bool
        return 
            if (d < 0) !b
            else if (d > 0) b
            else
                throw '$this.d should *never* be 0';

/* === Computed Fields === */

    public var length(get, never): Int;
    inline function get_length() return TMath.max(0, TMath.ceil(d / step));

    public var direction(get, never): Int;
    inline function get_direction():Int
        return 
            if (d > 0) 
                1;
            else 
                -1;

    var d(get, never): Int;
    inline function get_d():Int return (finish - start);

/* === Fields === */

    public var start(default, null): Int;
    public var finish(default, null): Int;
    public var step(default, null): Int;

    var __i: Int;
}
