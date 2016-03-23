package tannus.math;

import tannus.ds.Tree;
import tannus.ds.TreeNode;

import tannus.math.SearchTree;

using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;

class SearchTreeNode extends TreeNode {
	/* Constructor Function */
	public function new():Void {
		super();
	}

/* === Instance Methods === */

	/**
	  * get the 'position' of [this] Node (int x, int y)
	  */
	public function getPosition():NodePosition {
		return {'x': 0, 'y': 0};
	}

	/**
	  * the 'F' score of [this] Node
	  */
	public inline function fScore():Int {
		return (h + g);
	}

/* === Instance Fields === */

	public var h : Int;
	public var g : Int;
}

/* the coordinates of a Node */
typedef NodePosition = {
	var x : Int;
	var y : Int;
};
