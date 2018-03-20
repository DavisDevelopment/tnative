package tannus.geom2;

import tannus.ds.DataView;

import Std.*;
import tannus.math.TMath.*;
import tannus.math.TMath.min in minn;
import tannus.math.TMath.max in maxx;

using Slambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;

//@:expose
class VertexArray <T:Float> {
	/* Constructor Function */
	public function new(?points : Array<Point<T>>):Void {
		data = new Array();
		if (points != null) {
			data = points.copy();
		}
	}

/* === Instance Methods === */

    /**
      * get the Rect<T> for which the 'containsPoint' method would return 'true' for all Points in [this]
      */
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

    /**
      * get the Point at the given index
      */
	public inline function get(index : Int):Null<Point<T>> {
		return data[index];
	}

    /**
      * set the Point at the given index
      */
	public inline function set(index:Int, p:Point<T>):Point<T> {
		return (data[index] = p);
	}

    /**
      * push a new Point onto [this]
      */
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

    /**
      * get the index of [point]
      */
	public function indexOf(point : Point<T>):Int {
		for (i in 0...data.length) {
			if (data[i].equals( point )) {
				return i;
			}
		}
		return -1;
	}

    /**
      * create and return a deep-copy of [this]
      */
	public function clone():VertexArray<T> {
	    return map.fn(_.clone());
	}

	public inline function filter(f : Point<T>->Bool):VertexArray<T> {
		return new VertexArray(data.filter( f ));
	}

	public inline function map<A:Float>(f : Point<T>->Point<A>):VertexArray<A> {
		return new VertexArray(data.map( f ));
	}

    /**
      * remove [point] from [this]
      */
	public inline function remove(point : Point<T>):Bool {
		return data.remove( point );
	}

    /**
      * iterate over [this]
      */
	public function iterator():Iterator<Point<T>> {
		return data.iterator();
	}

	/**
	  * get [this] as a normal Array<Point<T>>
	  */
	public inline function toArray():Array<Point<T>> {
	    return data.copy();
	}

/* === Operators === */

    /**
      * create a new VertexArray<A> by applying [f] to each coordinate value of each point in [this]
      */
	public function mutate<A:Float>(f : T -> A):VertexArray<A> {
	    return map(function(point: Point<T>):Point<A> {
	        return point.mutate( f );
	    });
	}

	public function round():VertexArray<Int> {
		return mutate( TMath.round );
	}

	public function floor():VertexArray<Int> {
		return mutate( TMath.floor );
	}

	public function ceil():VertexArray<Int> {
		return mutate( TMath.ceil );
	}

/* === Computed Instance Fields === */

	public var length(get, never):Int;
	private inline function get_length():Int return data.length;

/* === Instance Fields === */

	private var data : Array<Point<T>>;
}
