package tannus.math;

import tannus.ds.Maybe;
import tannus.ds.FloatRange;
import haxe.Int64;

import Std.*;
import Math.*;
import tannus.math.TMath.*;

import haxe.macro.Expr;
import haxe.macro.Context;

using haxe.macro.ExprTools;
using tannus.macro.MacroTools;
using tannus.math.TMath;
using Lambda;
using tannus.ds.ArrayTools;

class Units {
    /* Convert grams to ounces */
    public static inline function ouncesToGrams(ounces : Float):Float {
        return (ounces * 28.349);
    }
    
    /* Convert ounces to grams */
    public static inline function gramsToOunces(grams : Float):Float {
        return (grams / 28.349);
    }
}