package tannus.ds;

import tannus.io.Ptr;
import haxe.ds.Vector;
import tannus.math.TMath.*;

import Std.*;

using StringTools;
using tannus.ds.StringUtils;

/* Class used to store values by coordinates */
class Grid<T> {
	/* Constructor Function */
	public function new(w:Int, h:Int):Void {
		this.w = w;
		this.h = h;
		data = new Vector(w * h);
	}

/* === Instance Methods === */

	/* set the given value at the given position */
	public function set(x:Int, y:Int, value:T):T {
		return data.set(index(x, y), value);
	}

	/* get the value stored at the given position */
	public function get(x:Int, y:Int):T {
		return data.get(index(x, y));
	}

	/* get a pointer to the value at the given position */
	public function at(pos : GridPos):Ptr<T> {
		var ref:Ptr<T> = new Ptr(get.bind(pos.x, pos.y), set.bind(pos.x, pos.y, _));
		ref.deleter = function() {
			remove(pos.x, pos.y);
		};
		return ref;
	}

	/* delete the value at the given coordinates */
	public function remove(x:Int, y:Int):Bool {
		var v:Null<T> = get(x, y);
		data.set(index(x, y), null);
		return (v != null);
	}

	/* iterate over [this] grid */
	public function iterator():GridValueIterator<T> {
		return new GridValueIterator( this );
	}

	/* iterate over all keys in [this] Grid */
	public function positions():GridPosIterator<T> {
		return new GridPosIterator( this );
	}

	/* the index of the given coordinates */
	public inline function index(x:Int, y:Int):Int {
		return (x + (y * w));
	}

/* === Computed Instance Fields === */

	/* the size of [this] Grid */
	public var length(get, never):Int;
	private inline function get_length():Int {
		return data.length;
	}

/* === Instance Fields === */

	public var w:Int;
	public var h:Int;
	public var data:Vector<T>;
}

/* class used for iteration over a grid */
private class GridValueIterator<T> {
	/* Constructor Function */
	public function new(g : Grid<T>):Void {
		grid = g;
		x = 0;
		y = 0;
	}

/* === Instance Methods === */

	/* determine whether a 'next' value exists */
	public function hasNext():Bool {
		return !(x == grid.w-1 && y == grid.h-1);
	}

	/* go to the next value */
	public function next():T {
		var value:T = grid.get(x, y);
		if (x >= (grid.w - 1)) {
			x = 0;
			y++;
		}
		else {
			x++;
		}
		return value;
	}

/* === Instance Fields === */

	public var grid : Grid<T>;
	public var x : Int;
	public var y : Int;
}

/* Class used to iterate over a Grid's keys */
private class GridPosIterator<T> {
	/* Constructor Function */
	public function new(g : Grid<T>):Void {
		grid = g;
		x = 0;
		y = 0;
	}

/* === Instance Methods === */

	/* whether there is a 'next item' in [this] Iterator */
	public function hasNext():Bool {
		return !(x == (grid.w - 1) && y == (grid.h - 1));
	}

	/* the 'next item' in [this] Iterator */
	public function next():GridPos {
		var pos:GridPos = new GridPos(x, y);
		if (x >= (grid.w - 1)) {
			x = 0;
			y++;
		}
		else {
			x++;
		}
		return pos;
	}

/* === Instance Fields === */

	private var grid : Grid<T>;
	private var x : Int;
	private var y : Int;
}

class GridPos {
	/* Constructor Function */
	public function new(x:Int, y:Int):Void {
		_x = x;
		_y = y;
	}

/* === Computed Instance Fields === */

	private var _x:Int;
	public var x(get, never):Int;
	private inline function get_x():Int return _x;

	private var _y:Int;
	public var y(get, never):Int;
	private inline function get_y():Int return _y;
}
