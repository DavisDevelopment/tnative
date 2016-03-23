package tannus.ds;

import tannus.io.Ptr;
import haxe.ds.Vector;
import tannus.math.TMath.*;

import Std.*;

using StringTools;
using tannus.ds.StringUtils;
using tannus.ds.ArrayTools;

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
	public function set(x:Int, y:Int, value:Null<T>):Null<T> {
		if (!((x >= w || x < 0) || (y >= h || y < 0))) {
			return data.set(index(x, y), value);
		} else return value;
	}

	/* get the value stored at the given position */
	public function get(x:Int, y:Int):Null<T> {
		if ((x >= w || x < 0) || (y >= h || y < 0)) {
			return null;
		}

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

	/* get a GridPos => (x, y) */
	public function pos(x:Int, y:Int):GridPos {
		return new GridPos(x, y);
	}

	/* get the position of the first instance of [value] in  [this] */
	public function posOf(value : T):Null<GridPos> {
		for (i in 0...data.length) {
			if (data.get( i ) == value) {
				return pos((i % w), int(i / w));
			}
		}
		return null;
	}

	/* get the value at the given position */
	public inline function valueAt(pos : GridPos):Null<T> {
		return get(pos.x, pos.y);
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

	/* the position of the given index */
	public inline function position(index : Int):GridPos {
		return new GridPos((index % w), int(index / w));
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
	public var data : Vector<T>;

/* === Static Methods === */

	/* Build a Grid<T> from an Array<T> */
	public static function fromArray<T>(dat:Array<T>, w:Int, h:Int):Grid<T> {
		var grid:Grid<T> = new Grid(w, h);
		grid.data = Vector.fromArrayCopy( dat );
		return grid;
	}

	/* Build a Grid<T> from an Array<Array<T>> */
	public static function fromArray2<T>(dat : Array<Array<T>>):Grid<T> {
		var h:Int = dat.length;
		if (h > 0) {
			var w:Int = dat[0].length;
			if (w <= 0) {
				throw 'GridError: Grid width must be >= 0';
			}
			return fromArray(dat.flatten(), w, h);
		}
		else {
			throw 'GridError: Grid height must be >= 0';
		}
	}
}

/* class used for iteration over a grid */
private class GridValueIterator<T> {
	/* Constructor Function */
	public function new(g : Grid<T>):Void {
		grid = g;
		it = grid.positions();
	}

/* === Instance Methods === */

	/* determine whether a 'next' value exists */
	public function hasNext():Bool {
		return it.hasNext();
	}

	/* go to the next value */
	public function next():T {
		var p = it.next();
		return grid.get(p.x, p.y);
	}

/* === Instance Fields === */

	public var grid : Grid<T>;
	public var it : GridPosIterator<T>;
}

/* Class used to iterate over a Grid's keys */
@:access( tannus.ds.Grid )
private class GridPosIterator<T> {
	/* Constructor Function */
	public function new(g : Grid<T>):Void {
		grid = g;
		it = (0 ... g.data.length);
	}

/* === Instance Methods === */

	/* whether there is a 'next item' in [this] Iterator */
	public function hasNext():Bool {
		return it.hasNext();
	}

	/* the 'next item' in [this] Iterator */
	public function next():GridPos {
		return grid.position(it.next());
	}

/* === Instance Fields === */

	private var grid : Grid<T>;
	private var it : IntIterator;
}

class GridPos {
	/* Constructor Function */
	public function new(x:Int, y:Int):Void {
		_x = x;
		_y = y;
	}

/* === Instance Methods === */

	/* the Pos to the left of [this] one */
	public inline function left():GridPos return new GridPos(x-1, y);
	public inline function right():GridPos return new GridPos(x+1, y);
	public inline function top():GridPos return new GridPos(x, y-1);
	public inline function bottom():GridPos return new GridPos(x, y+1);

	/**
	  * convert [this] Pos into a String
	  */
	public function toString():String {
		return '($x, $y)';
	}

/* === Computed Instance Fields === */

	private var _x:Int;
	public var x(get, never):Int;
	private inline function get_x():Int return _x;

	private var _y:Int;
	public var y(get, never):Int;
	private inline function get_y():Int return _y;
}
