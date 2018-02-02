package tannus.geom2;

import tannus.ds.IComparable;

using tannus.ds.ArrayTools;
using tannus.math.TMath;

class Area <T:Float> implements IComparable<Area<T>> {
	/* Constructor Function */
	public inline function new(w:T, h:T):Void {
		width = w;
		height = h;
	}

/* === Instance Methods === */

    // clone
	public inline function clone():Area<T> {
		return new Area(width, height);
	}

	public inline function equals(o: Area<T>):Bool return (width == o.width && height == o.height);
	public inline function nequals(o: Area<T>):Bool return (width != o.width || height != o.height);

    // stringify
	public inline function toString():String {
		return ('${width}x${height}');
	}

	// transform into a Rect
	public inline function toRect():Rect<T> {
		return new Rect(untyped 0, untyped 0, width, height);
	}

	public inline function round():Area<Int> return new Area(width.round(), height.round());
	public inline function floor():Area<Int> return new Area(width.floor(), height.floor());
	public inline function ceil():Area<Int> return new Area(width.ceil(), height.ceil());
	public inline function int():Area<Int> return new Area(width.int(), height.int());
	public inline function float():Area<Float> return new Area(width.float(), height.float());

    // apply [f] to both [width] and [height]
	private function apply<A:Float>(f:Float -> A):Area<A> {
		return new Area(f(cast width), f(cast height));
	}

    // compare [this] Area to [a]
	public function compareTo(a : Area<T>):Int {
		var ww = Reflect.compare(width, a.width);
		if (ww != 0) {
			return ww;
		}
		else {
			return Reflect.compare(height, a.height);
		}
	}

/* === Instance Fields === */

	public var width(default, null):T;
	public var height(default, null):T;

/* === Class Methods === */

    public static inline function make<T:Float>(width:T, height:T):Area<T> return new Area(width, height);
    public static inline function fromArray<T:Float>(array: Array<T>):Area<T> return make(array[0], array[1]);
    public static inline function fromPoint<T:Float>(point: Point<T>):Area<T> return make(point.x, point.y);
    public static inline function fromRect<T:Float>(rect: Rect<T>):Area<T> return make(rect.width, rect.height);
}
