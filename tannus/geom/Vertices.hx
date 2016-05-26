package tannus.geom;

import tannus.geom.Point;
import tannus.geom.Line;

using Lambda;
using tannus.ds.ArrayTools;

@:forward
abstract Vertices (VertexArray) from VertexArray to VertexArray {
	/* Constructor Function */
	public inline function new(?v:Array<Point>):Void {
		this = new VertexArray( v );
	}

/* === Type Corrections === */

	public inline function clone():Vertices return this.clone();
	public inline function map(f:Point->Point):Vertices return this.map( f );

	@:arrayAccess
	public inline function get(i : Int):Null<Point> {
		return this.get( i );
	}

	@:arrayAccess
	public inline function set(i:Int, p:Point):Point {
		return this.set(i, p);
	}

	@:op(A += B)
	public inline function isum(other : Vertices):Vertices return this.append( other );

	@:op(A + B)
	public inline function sum(other : Vertices):Vertices return this.concat( other );

/* === Type Casting === */

	/* to Array<Point> */
	@:to
	@:access(tannus.geom.VertexArray)
	inline function toPoints():Array<Point> {
		return [for (p in this) p.clone()];
	}

	/* from Array<Point> */
	@:from
	static inline function fromPoints(list : Array<Point>):Vertices {
		return new Vertices( list );
	}

	/* to Array<Line> */
	@:to
	inline function toLines():Array<Line> {
		return (this.lines);
	}

	/* from Array<Line> */
	@:from
	static inline function fromLines(lines : Array<Line>):Vertices {
		return new Vertices([for (l in lines) [l.start, l.end]].flatten());
	}

	/* from Shape */
	@:from
	static inline function fromShape(s : tannus.geom.Shape):Vertices {
		return s.getVertices();
	}
}

private typedef Arr2<T> = Array<Array<T>>;
