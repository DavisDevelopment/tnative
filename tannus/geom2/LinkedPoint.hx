package tannus.geom2;

import tannus.io.Ptr;
import tannus.ds.DataView;
import tannus.ds.data.BoundData;

//import Math.*;
import tannus.math.TMath.*;

import haxe.macro.Expr;
import haxe.macro.Context;

using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;
using haxe.macro.ExprTools;
using tannus.macro.MacroTools;

class LinkedPoint<T:Float> extends Point<T> {
	/* Constructor Function */
	public function new(x_ref:Ptr<T>, y_ref:Ptr<T>, z_ref:Ptr<T>):Void {
		super(untyped 0, untyped 0, untyped 0);

        #if !js
		d = new BoundData([x_ref, y_ref, z_ref]);
	    #else
	    inline function desc(x : Ptr<T>) {
	        return {get:(function() return x.get()), set: (function(v) return x.set(v))};
	    }
	    tannus.html.JSTools.defineProperties(this, untyped {
            x: desc( x_ref ),
            y: desc( y_ref ),
            z: desc( z_ref )
	    });
	    #end
	}

/* === Static Methods === */

	/**
	  * macro-licious method to create a LinkedPoint
	  */
	public static macro function create<T:Float>(values : Array<ExprOf<T>>):ExprOf<LinkedPoint<T>> {
		values = values.map(function( e ) {
			return macro tannus.io.Ptr.create( $e );
		});
		var x:ExprOf<Ptr<T>> = values[0];
		var y:ExprOf<Ptr<T>> = values[1];
		var z:ExprOf<Ptr<T>> = values[2];
		return macro new LinkedPoint($x, $y, $z);
	}
}
