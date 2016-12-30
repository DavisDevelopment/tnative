package tannus.geom2;

import tannus.ds.IComparable;

using tannus.ds.ArrayTools;

@:forward
abstract Area<T:Float> (CArea<T>) from CArea<T> to CArea<T> {
	public inline function new(w:T, h:T):Void {
		this = new CArea(w, h);
	}
	@:from
	public static inline function fromArray<T:Float>(a : Array<T>):Area<T> {
		return new Area(a[0], a[1]);
	}
	@:from
	public static inline function fromRect<T:Float>(r : Rect<T>):Area<T> {
		return new Area(r.w, r.h);
	}
	@:to
	public inline function toRect():Rect<T> return this.toRect();
	@:from
	public static function fromString(s : String):Area<Float> {
		return fromArray(s.split('x').map( Std.parseFloat ));
	}
}

class CArea<T:Float> implements IComparable<CArea<T>> {
	/* Constructor Function */
	public function new(w:T, h:T):Void {
		width = w;
		height = h;
	}

/* === Instance Methods === */

	public function clone():Area<T> {
		return new Area(width, height);
	}

	public function toString():String {
		return ('${width}x${height}');
	}
	public function toRect():Rect<T> {
		return new Rect(cast 0, cast 0, cast width, cast height);
	}

	public inline function round():Area<Int> return apply( Math.round );
	public inline function floor():Area<Int> return apply( Math.floor );
	public inline function ceil():Area<Int> return apply( Math.ceil );

	private function apply<A:Float>(f:Float -> A):Area<A> {
		return new Area(f(cast width), f(cast height));
	}

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
}
