package tannus.geom;

import tannus.geom.Point;
import tannus.geom.Line;

import haxe.ds.Vector;

@:forward(length)
abstract Vertices (Array<Point>) {
	/* Constructor Function */
	public inline function new(?points:Array<Point>):Void {
		this = (points != null ? points : new Array());
	}

/* === Instance Methods === */

	/**
	  * Get the Point at offset [i]
	  */
	@:arrayAccess
	public inline function get(i : Int):Null<Point> {
		return (this[i]);
	}

	/**
	  * Assign a new Point to offset [i]
	  */
	@:arrayAccess
	public inline function set(i:Int, np:Point):Point {
		return (this[i] = np);
	}

	/**
	  * Iterate over [this] Vertices
	  */
	public inline function iterator():Iterator<Point> {
		return (this.iterator());
	}

	/**
	  * Add a new Point
	  */
	public inline function add(pt : Point):Int {
		return this.push( pt );
	}

	/**
	  * Undo an addition of a Point
	  */
	public inline function undo():Null<Point> {
		return this.pop();
	}

	/**
	  * Append another Vertices instance onto [this] one
	  */
	public inline function append(other : Vertices):Void {
		this = (this.concat(other.toPoints()));
	}

	/**
	  * Apply function [f] to each Point of [this] Vertices
	  */
	public inline function transform(f : Point->Void):Void {
		for (point in self)
			f( point );
	}

	/**
	  * Create and return a copy of [this]
	  */
	public inline function clone():Vertices {
		return new Vertices(this.copy());
	}

	/**
	  * Calculate the Lines created by [this] Vertices
	  */
	public function calculateLines(?close:Bool = false):Array<Line> {
		var lines:Array<Line> = new Array();
		var ln = lines.push.bind(_);
		var i:Int = 0;
		var last:Null<Point> = null;
		var verts = self;
		while (i < verts.length) {
			var start:Point = verts[i];

			if (last == null)
				last = start;
			else {
				var end:Point = last;
				ln(new Line(end, start));
				last = start;
			}

			i++;
		}

		if (close) {
			ln(new Line(verts.last, verts.first));
		}

		return lines;
	}

/* === Instance Fields === */

	/**
	  * internal reference to [this] as a Vertices instance
	  */
	private var self(get, never):Vertices;
	private inline function get_self() return new Vertices(this);

	/**
	  * The first Point
	  */
	public var first(get, set):Null<Point>;
	private inline function get_first():Null<Point> {
		return (this[0]);
	}
	private inline function set_first(nf : Null<Point>):Null<Point> {
		if (nf == null)
			this.shift();
		else
			this[0] = nf;
		return first;
	}

	/**
	  * The last Point
	  */
	public var last(get, set):Null<Point>;
	private inline function get_last():Null<Point> {
		return (this[this.length - 1]);
	}
	private inline function set_last(np : Null<Point>):Null<Point> {
		if (np == null)
			this.pop();
		else
			this[this.length - 1] = np;
		return last;
	}

/* === Implicit Casting === */

	/* To Array<Array<Float>> */
	@:to
	public inline function toFloatVerticeArray():Arr2<Float> {
		return [for (p in self) [p.x, p.y]];
	}

	/* From Array<Array<Float>> */
	@:from
	public static inline function fromFloatVerticeArray(fva : Arr2<Float>):Vertices {
		return new Vertices(fva.map(function(row) return Point.fromFloatArray(row)));
	}

	/* To Array<Array<Int>> */
	@:to
	public inline function toIntVerticeArray():Arr2<Int> {
		return [for (p in self) [p.ix, p.iy]];
	}

	/* From Array<Array<Int>> */
	@:from
	public static inline function fromIntVerticeArray(fva : Arr2<Int>):Vertices {
		return new Vertices(fva.map(function(row) return Point.fromIntArray(row)));
	}

	/* To Array<Point> */
	@:to
	public inline function toPoints():Array<Point> return this;

	/* From Array<Point> */
	@:from
	public static inline function fromPoints(pa : Array<Point>):Vertices {
		return new Vertices(pa);
	}

	/* To Array<Line> */
	@:to
	public inline function toLines():Array<Line> {
		return calculateLines(true);
	}

	/* From Array<Line> */
	@:from
	public static inline function fromLines(la : Array<Line>):Vertices {
		return new Vertices(la.map(function(l) return l.start));
	}
}

private typedef Arr2<T> = Array<Array<T>>;
