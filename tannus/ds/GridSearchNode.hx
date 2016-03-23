package tannus.ds;

import tannus.ds.Tree;
import tannus.ds.TreeNode;
import tannus.ds.Grid;

import tannus.math.SearchTree;
import tannus.math.SearchTreeNode;

using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;

@:access( tannus.ds.GridSearch )
class GridSearchNode<T> extends SearchTreeNode {
	/* Constructor Function */
	public function new(pos:GridPos, tree:GridSearch<T>):Void {
		super();

		this.pos = pos;
		this.tree = tree;
	}

/* === Instance Methods === */

	/* the 'position' of [this] */
	override public function getPosition():NodePosition {
		return {
			'x': pos.x,
			'y': pos.y
		};
	}

	/**
	  * get the adjacent nodes of [this] Shit
	  */
	public function neighbors():Array<GridSearchNode<T>> {
		var poslist:Array<GridPos> = [pos.top(), pos.left(), pos.bottom(), pos.right()];
		var neighbors = poslist.macmap(tree.getNodeAt(_));
		neighbors = neighbors.macfilter(_ != null);
		return neighbors;
	}

	/**
	  * convert [this] Node to a String
	  */
	public function toString():String {
		return pos.toString();
	}

/* === Computed Instance Fields === */

	public var value(get, never):Null<T>;
	private inline function get_value():Null<T> {
		return grid.valueAt( pos );
	}

	private var grid(get, never):Grid<T>;
	private inline function get_grid():Grid<T> {
		return tree.grid;
	}

/* === Instance Fields === */

	
	private var tree : GridSearch<T>;
	public var pos : GridPos;
}
