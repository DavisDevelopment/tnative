package tannus.geom2;

import tannus.ds.DataView;

import Std.*;
import tannus.math.TMath.*;
import haxe.macro.Expr;

using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;
using tannus.macro.MacroTools;

@:forward
abstract Rect<T:Float> (CRect<T>) from CRect<T> to CRect<T> {
	public inline function new(?x:T, ?y:T, ?width:T, ?height:T):Void {
	    this = new CRect(x, y, width, height);
	}

	@:op(A == B)
	public static inline function overloadedEq<T:Float>(a:Rect<T>, b:Rect<T>):Bool {
	    throw 'EQ';
	    return a.equals( b );
	}

	@:op(A != B)
	public static inline function overloadedNeq<T:Float>(a:Rect<T>, b:Rect<T>):Bool {
	    throw 'NEQ';
	    return a.nequals( b );
	}
}

@:expose
class CRect <T:Float> {
	/* Constructor Function */
	public function new(?x:T, ?y:T, ?width:T, ?height:T):Void {
	    #if !js
		d = new DataView(4, untyped 0);

		if (x == null) x = untyped 0;
		if (y == null) y = untyped 0;
		if (width == null) width = untyped 0;
		if (height == null) height = untyped 0;

		d.sets([x, y, width, height]);
	    #else
		if (x == null) x = untyped 0;
		if (y == null) y = untyped 0;
		if (width == null) width = untyped 0;
		if (height == null) height = untyped 0;
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	    #end
	}

/* === Instance Methods === */

	/**
	  * create and return a deep-copy of [this]
	  */
	public inline function clone():Rect<T> {
		return new Rect(x, y, w, h);
	}

	public inline function set(nx:T, ny:T, nw:T, nh:T):Void {
	    x = nx;
	    y = ny;
	    width = nw;
	    height = nh;
	}

	/**
	  * copy data from the given Rect<T>
	  */
	public inline function pull(src : Rect<T>):Void {
	    set(src.x, src.y, src.width, src.height);
	}

	/**
	  * test whether [this] Rect is equal to [other]
	  */
	public inline function equals(o : Rect<T>):Bool {
		return (
			(x == o.x) &&
			(y == o.y) &&
			(w == o.w) &&
			(h == o.h)
		);
	}

	public inline function nequals(o : Rect<T>):Bool {
		return (
			(x != o.x) ||
			(y != o.y) ||
			(w != o.w) ||
			(h != o.h)
		);
	}

	/**
	  * check whether the given coordinates fall within [this] Rect
	  */
	public inline function contains(ox:Float, oy:Float):Bool {
		return (
			(ox > x && (ox < (x + w))) &&
			(oy > y && (oy < (y + h)))
		);
	}

	/**
	  * check whether the given Point falls within [this] Rect
	  */
	public inline function containsPoint(p : Point<Float>):Bool {
		return contains(p.x, p.y);
	}

	/**
	  * get the corners of [this] Rect
	  */
	public function getCorners():Array<Point<T>> {
		return [getTopLeft(), getTopRight(), getBottomLeft(), getBottomRight()];
	}

	/**
	  * check whether the given Rect is completely inside of [this] one
	  */
	public function containsRect(o : Rect<Float>):Bool {
		var ocl = o.getCorners();
		for (p in ocl) {
			if (!containsPoint( p )) {
				return false;
			}
		}
		return true;
	}

	/**
	  * check whether [this] Rect overlaps at all with the given one
	  */
	public function overlapsWith(o : Rect<Float>):Bool {
		var ocl = o.getCorners();
		if (containsPoint( o.center )) {
			return true;
		}
		else {
			for (p in o.getCorners()) {
				if (containsPoint( p )) {
					return true;
				}
			}
			return false;
		}
	}

	/**
	  * modify the size of [this] Rect
	  */
	public function enlarge(dw:T, dh:T):Void {
		w += dw;
		h += dh;
		x -= Math.round(dw / 2);
		y -= Math.round(dh / 2);
	}

	public function scale(?sw:T, ?sh:T):Rect<T> {
	    var ratio:Float;
	    if (sw != null) {
	        ratio = (sw / width);
	        width = sw;
	        height = (untyped ratio * height);
	    }
        else if (sh != null) {
            ratio = (sh / height);
            height = sh;
            width = (untyped ratio * width);
        }
        return this;
	}

	public inline function scaled(?sw:Float, ?sh:Float):Rect<Float> {
	    return clone().scale(untyped sw, untyped sh).float();
	}

	/**
	  * Convert [this] Rect to a String
	  */
	public inline function toString():String {
		return 'Rect($x, $y, $width, $height)';
	}

	/**
	  * Convert [this] into an Array
	  */
	public inline function toArray():Array<T> {
		return [x, y, w, h];
	}

	//public inline function toRectangle():tannus.geom.Rectangle 
		//return tannus.geom.Rectangle.fromRect2D( this );

	public function getTopLeft():Point<T> {
	    return pt(x, y);
	}

	public function getTopRight():Point<T> {
	    return pt(x+w, y);
	}

	public function getBottomLeft():Point<T> {
	    return pt(x, y+h);
	}

	public function getBottomRight():Point<T> {
	    return pt(x+w, y+h);
	}

	private static inline function pt<T:Float>(x:T, y:T):Point<T> { return new Point(x, y); }

	/**
	  * Round [this] Rect
	  */
	public inline function int():Rect<Int> return trans(_.int());
	public inline function float():Rect<Float> return trans(_.float());
	public inline function round():Rect<Int> return trans(_.round());
	public inline function floor():Rect<Int> return trans(_.floor());
	public inline function ceil():Rect<Int> return trans(_.ceil());

	/**
	  * apply the given function to all values in [this] Rect
	  */
	private inline function apply<A:Float>(f : T->A):Rect<A> {
		return new Rect(f(x), f(y), f(w), f(h));
	}

	public macro function trans<Out:Float>(self:ExprOf<Rect<T>>, varArgs:Array<Expr>):ExprOf<Rect<Out>> {
	    var cargs:Array<Expr> = [macro $self.x, macro $self.y, macro $self.width, macro $self.height];
	    var u:Expr = macro _;
	    switch ( varArgs ) {
            case [et]:
                cargs = [
                    et.replace(u, cargs[0]),
                    et.replace(u, cargs[1]),
                    et.replace(u, cargs[2]),
                    et.replace(u, cargs[3])
                ];

            case [etx, ety, etw, eth]:
                cargs = [
                    etx.replace(u, cargs[0]),
                    ety.replace(u, cargs[1]),
                    etw.replace(u, cargs[2]),
                    eth.replace(u, cargs[3])
                ];

            default:
                throw 'Error: Invalid varargs to tannus.geom2.Rect.trans';
	    }

	    return macro new tannus.geom2.Rect($a{cargs});
	}

/* === Computed Instance Fields === */

#if !js
	public var x(get, set):T;
	private inline function get_x():T return d[0];
	private inline function set_x(v : T):T return (d[0] = v);
	
	public var y(get, set):T;
	private inline function get_y():T return d[1];
	private inline function set_y(v : T):T return (d[1] = v);
	
	public var width(get, set):T;
	private inline function get_width():T return d[2];
	private inline function set_width(v : T):T return (d[2] = v);
	
	public var height(get, set):T;
	private inline function get_height():T return d[3];
	private inline function set_height(v : T):T return (d[3] = v);
#end
	
	public var w(get, set):T;
	private inline function get_w():T return width;
	private inline function set_w(v : T):T return (width = v);
	
	public var h(get, set):T;
	private inline function get_h():T return height;
	private inline function set_h(v : T):T return (height = v);

	public var centerX(get, set):Float;
	private inline function get_centerX():Float return (x + (w / 2));
	private inline function set_centerX(v : Float):Float {
	    return (x = (cast (v - w / 2)));
	}

	public var centerY(get, set):Float;
	private inline function get_centerY():Float return (y + (h / 2));
	private inline function set_centerY(v : Float):Float {
	    return (y = (cast (v - h / 2)));
	}

	public var center(get, set):Point<Float>;
	@:deprecated
	private function get_center():Point<Float> {
		var z:Float = 0;
		//return LinkedPoint.create(centerX, centerY, z);
		return new Point(centerX, centerY);
	}
	private function set_center(v : Point<Float>):Point<Float> {
		centerX = v.x;
		centerY = v.y;
		return center;
	}

/* === Instance Fields === */

#if !js
	private var d : DataView<T>;
#else
    public var x : T;
    public var y : T;
    public var width : T;
    public var height : T;
#end
}
