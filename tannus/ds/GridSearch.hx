package tannus.ds;

import tannus.ds.Grid;
import tannus.math.SearchTree;
import tannus.math.SearchTreeNode;

import Std.*;
import Math.*;
import tannus.math.TMath.*;

using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;

class GridSearch<T> extends SearchTree<GridSearchNode<T>> {
	/* Constructor Function */
	public function new(g:Grid<T>, opts:GridSearchOptions<T>):Void {
		super();

		grid = g;
		start_pos = new GridPos(0, 0);
		barrierNodes = new Array();
		options = opts;

		findAllNodes();
	}

/* === Instance Methods === */

	/**
	  * Find all nodes in the Grid
	  */
	private function findAllNodes():Void {
		nodes = new Grid(grid.w, grid.h);
		for (pos in grid.positions()) {
			var ref = nodes.at( pos );
			var node = new GridSearchNode(pos, this);
			ref.set( node );
		}

		for (node in nodes) {
			if (endNode == null && options.isGoal( node.value )) {
				endNode = node;
			}
			else if (!options.isWalkable( node.value )) {
				barrierNodes.push( node );
			}
			else {
				if (root == null) {
					root = node;
				}
			}
		}

		currentNode = root;
	}

	/**
	  * Get the Node at the given coordinates
	  */
	public function getNodeAt(pos : GridPos):Null<GridSearchNode<T>> {
		return nodes.valueAt( pos );
	}

	/**
	  * get the Node to start the search at
	  */
	override public function getStartNode():GridSearchNode<T> {
		return root;
	}

	override public function isWalkable(node : GridSearchNode<T>):Bool {
		return !barrierNodes.has( node );
	}

	@:access( tannus.ds.GridSearchNode )
	override public function getAdjacentNodes(node : GridSearchNode<T>):Array<GridSearchNode<T>> {
		return node.neighbors();
	}

	@:access( tannus.ds.GridSearchNode )
	override public function compareNodes(l:GridSearchNode<T>, r:GridSearchNode<T>):Bool {
		return (l == r);
	}

/* === Instance Fields === */

	private var grid : Grid<T>;
	private var nodes : Grid<GridSearchNode<T>>;
	private var start_pos : GridPos;
	public var barrierNodes : Array<GridSearchNode<T>>;
	public var options : GridSearchOptions<T>;
}

typedef GridSearchOptions<T> = {
	function isGoal(value : T):Bool;
	function isWalkable(value : T):Bool;
};
