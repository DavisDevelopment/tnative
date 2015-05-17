package tannus.geom;

import tannus.ds.TwoTuple;
import tannus.geom.Rectangle;

#if python
	import python.Tuple;
	import python.Tuple.Tuple2;
#end

abstract Area (TwoTuple<Float, Float>) {
	public inline function new(w:Float=0, h:Float=0):Void {
		this = new TwoTuple(w, h);
	}

	/* 'width' field */
	public var width(get, set):Float;
	private inline function get_width() return this.one;
	private inline function set_width(nw:Float) return (this.one = nw);

	/* 'height' field */
	public var height(get, set):Float;
	private inline function get_height() return (this.two);
	private inline function set_height(nh:Float) return (this.two = nh);

/* === Instance Methods === */

	/**
	  * Create and Return a copy of [this]
	  */
	public inline function clone():Area {
		return new Area(width, height);
	}

/* === Type Casting === */

	/* To TwoTuple<Float, Float> */
	@:to
	public inline function toFloatTuple():TwoTuple<Float, Float> {
		return this;
	}

	/* To TwoTuple<Int, Int> */
	@:to
	public inline function toIntTuple():TwoTuple<Int, Int> {
		return new TwoTuple(i(width), i(height));
	}

	/* From TwoTuple<Number, Number> */
	@:from
	public static inline function fromTwoTuple<T : Float>(t : TwoTuple<T, T>):Area {
		return new Area(t.one, t.two);
	}

	/* To Rectangle */
	@:to
	public inline function toRectangle():Rectangle {
		return new Rectangle(0, 0, width, height);
	}

	/* From Rectangle */
	@:from
	public static inline function fromRectangle(r : Rectangle):Area {
		return new Area(r.w, r.h);
	}

	/* To String */
	@:to
	public function toString():String {
		return 'Area(width=$width, height=$height)';
	}

	#if java
	/* To java.awt.Dimension */
	@:to
	public function toJavaDimension():java.awt.Dimension {
		return new java.awt.Dimension(i(width), i(height));
	}

	@:from
	public static function fromJavaDimension(d : java.awt.Dimension):Area {
		return new Area(d.width, d.height);
	}
	#end

	#if python
		/* To python.Tuple2<Float, Float> */
		@:to
		public inline function toPythonTupleF():Tuple2<Float, Float> {
			return (toFloatTuple().toPythonTuple());
		}

		/* From python.Tuple2<Float, Float> */
		@:from
		public static inline function fromPythonTupleF(t : Tuple2<Float, Float>):Area {
			return new Area(t._1, t._2);
		}

		/* To python.Tuple2<Int, Int> */
		@:to
		public inline function toPythonTupleI():Tuple2<Int, Int> {
			return (toIntTuple().toPythonTuple());
		}

		/* From python.Tuple2<Int, Int> */
		@:from
		public static inline function fromPythonTupleI(t : Tuple2<Int, Int>):Area {
			return new Area(t._1, t._2);
		}

		/* To python.Tuple<Float> */
		@:to
		public inline function toGenericPythonTupleF():Tuple<Float> {
			return new Tuple([width, height]);
		}

		/* To python.Tuple<Int> */
		@:to
		public inline function toGenericPythonTupleI():Tuple<Int> {
			return new Tuple([i(width), i(height)]);
		}

		/* From python.Tuple<Float> */
		@:from
		public static inline function fromGenericPythonTuple<T : Float>(t : Tuple<T>):Area {
			return new Area(t[0], t[1]);
		}
	#end

	private static inline function i(f:Float):Int return Math.round(f);
}

class OldArea {
	/* Constructor Function */
	public function new(w:Float=0, h:Float=0):Void {
		width = w;
		height = h;
	}

/* === Instance Methods === */

	public var width : Float;
	public var height : Float;
}
