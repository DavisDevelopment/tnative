package tannus.geom2;

import tannus.ds.DataView;

import Std.*;
import tannus.math.TMath.*;
import tannus.math.TMath.min in minn;
import tannus.math.TMath.max in maxx;

using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;

class VertexArray<T:Float> {
	/* Constructor Function */
	public function new(?points : Array<Point<T>>):Void {
		data = new Array();
		if (points != null) {
			data = points.copy();
		}
	}

/* === Instance Methods === */

	public function getContainingRect():Rect<T> {
		var minp:Null<Point<T>> = null;
		var maxp:Null<Point<T>> = null;
		for (i in 0...data.length) {
			var p = data[i];
			if (minp == null) {
				minp = p.clone();
			}
			else {
				minp.x = minn(minp.x, p.x);
				minp.y = minn(minp.y, p.y);
			}
			if (maxp == null) {
				maxp = p.clone();
			}
			else {
				maxp.x = maxx(maxp.x, p.x);
				maxp.y = maxx(maxp.y, p.y);
			}
		}
		return new Rect(minp.x, minp.y, (maxp.x - minp.x), (maxp.y - minp.y));
	}

	/**
	  * Iterate over the pairs of Points in [this] VertexArray
	  */
	public function iterPairs(f:Point<T>->Point<T>->Void, close:Bool=true):Void {
		var index:Int = 1;
		var prevPoint:Point<T> = get( 0 );
		while (index < length) {
			var point:Point<T> = get( index );
			f(prevPoint, point);
			prevPoint = point;
			index++;
		}
		if ( close )
			f(prevPoint, get( 0 ));
	}

	/**
	  * Calculate the individual line segments that make up [this] VertexArray
	  */
	public function getLines(?close : Bool):Array<Line<T>> {
		var lines:Array<Line<T>> = new Array();
		iterPairs(function(a, b) {
			lines.push(new Line(a, b));
		}, close);
		return lines;
	}

	public inline function get(index : Int):Null<Point<T>> {
		return data[index];
	}
	public inline function set(index:Int, p:Point<T>):Point<T> {
		return (data[index] = p);
	}
	public inline function push(p : Point<T>):Void {
		data.push( p );
	}
	public inline function pop():Null<Point<T>> {
		return data.pop();
	}
	public inline function unshift(p : Point<T>):Void {
		data.unshift( p );
	}
	public inline function shift():Null<Point<T>> {
		return data.shift();
	}
	public inline function insert(index:Int, p:Point<T>):Void {
		data.insert(index, p);
	}
	public function indexOf(point : Point<T>):Int {
		for (i in 0...data.length) {
			if (data[i].equals( point )) {
				return i;
			}
		}
		return -1;
	}
	public inline function clone():VertexArray<T> {
		return new VertexArray(data.macmap(_.clone()));
	}
	public inline function filter(f : Point<T>->Bool):VertexArray<T> {
		return new VertexArray(data.filter( f ));
	}
	public inline function map<A:Float>(f : Point<T>->Point<A>):VertexArray<A> {
		return new VertexArray(data.map( f ));
	}
	public inline function remove(point : Point<T>):Bool {
		return data.remove( point );
	}
	public inline function iterator():Iterator<Point<T>> {
		return data.iterator();
	}

/* === Operators === */

	public function mutate<A:Float>(f : T->A):VertexArray<A> {
		return map(function(x) return x.mutate( f ));
	}
	public inline function round():VertexArray<Int> {
		return mutate( Math.round );
	}
	public inline function floor():VertexArray<Int> {
		return mutate( Math.floor );
	}
	public inline function ceil():VertexArray<Int> {
		return mutate( Math.ceil );
	}

/* === Computed Instance Fields === */

	public var length(get, never):Int;
	private inline function get_length():Int return data.length;

/* === Instance Fields === */

	private var data : Array<Point<T>>;
}
