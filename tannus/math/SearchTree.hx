package tannus.math;

import tannus.ds.Tree;
import tannus.ds.TreeNode;

import Std.*;
import Math.*;
import tannus.math.TMath.*;

using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;

class SearchTree<T : SearchTreeNode> extends Tree<T> {
	/* Constructor Function */
	public function new():Void {
		super();

		openedList = new Array();
		closedList = new Array();
	}

/* === Instance Methods === */

	/**
	  * search [this] Tree for a path to a Node for which isEndNode returns true
	  */
	public function search():Null<Array<T>> {
		scoreNode( currentNode );
		openedList.push( currentNode );

		while (openedList.length > 0) {
			currentNode = openedList.macmin(_.fScore());

			/* result found -- return traced path */
			if (compareNodes(currentNode, endNode)) {
				var cn = currentNode;
				var trace_back:Array<T> = new Array();

				while (cn.parentNode != null) {
					trace_back.push( cn );
					cn = cast cn.parentNode;
				}

				trace_back.reverse();
				return trace_back;
			}

			/* get adjacent nodes */
			var neighbors = getAdjacentNodes( currentNode );
			closeNode( currentNode );

			for (node in neighbors) {
				if (closedList.has( node ) || !isWalkable( node )) {
					trace('node either could not be walked, or was already closed');
					continue ;
				}

				// the best score we've seen yet (maybe)
				var gscore:Int = (currentNode.g + 1);
				var best:Bool = false;

				/* this is the first time we encounter [this] Node, so it's the best */
				if (!openedList.has( node )) {
					best = true;
					openNode( node );
					trace('node was opened');
				}

				/* we've seen this Node before, but it's better now */
				else if (gscore < node.g) {
					best = true;
				}

				if ( best ) {
					currentNode.append( node );
					node.g = gscore;
				}
			}
		}

		return null;
	}

	/**
	  * get the Node the search starts from
	  */
	public function getStartNode():T {
		throw 'tannus.math.SearchTree::getStartNode is not implemented in the base-class, and should be overridden by extending classes';
		return endNode;
	}

	/**
	  * calculate the 'score' of the given Node
	  */
	public function scoreNode(node : T):Void {
		node.h = heuristic(node, endNode);
	}

	/**
	  * 'open' the given Node
	  */
	public function openNode(node : T):Void {
		openedList.push( node );
		currentNode.append( node );
		scoreNode( node );
	}

	/**
	  * 'close' the given Node
	  */
	public function closeNode(node : T):Void {
		closedList.push( node );
		openedList.remove( node );
	}

	/**
	  * heuristic calculation
	  */
	public function heuristic(left:T, right:T):Int {
		var l = left.getPosition();
		var r = right.getPosition();

		return int(abs(r.x - l.x) + abs(r.y - l.y));
	}

	/**
	  * check that the given Node is walkable
	  */
	public function isWalkable(node : T):Bool {
		throw 'tannus.math.SearchTree::isWalkable is not implemented in the base-class, and should be overridden by extending classes';
		return true;
	}

	/**
	  * get the 'neighbors' (adjacent Nodes) of the given Node
	  */
	public function getAdjacentNodes(node : T):Array<T> {
		throw 'tannus.math.SearchTree::getAdjacentNodes is not implemented in the base-class, and should be overridden by extending classes';
		return new Array();
	}

	/**
	  * check whether two Nodes are identical
	  */
	public function compareNodes(left:T, right:T):Bool {
		return (left == right);
	}


/* === Instance Fields === */

	private var openedList : Array<T>;
	private var closedList : Array<T>;

	public var currentNode : Null<T>;
	public var endNode : T;
}

/*

- maintain a list of 'open' Nodes (Nodes which have not been ruled out as part of the solution

- maintain a list of 'closed' Nodes (Nodes which have been confirmed to NOT be part of the solution

- find the Node  returned the lowest value
	- this Node is now the 'current' Node
	- move it to the 'closed' list
	- for each Node returned by ('current' Node).getAdjacentNodes()
		- if [tree].isWalkableNode returns `false` OR it is already in the 'closed' list, ignore it
		- otherwise, if it is not on the 'open' list
			- add it to the 'open' list
			- append it to [current Node]
			- calculate the H, F, and G scores of this Node
		- if it is already on the 'open' list
			- check whether this Node is better than [current Node], in terms of it's G score
				- (lower G score == better)
			- if the Node is found to better
				- append it to [current Node]
				- make this Node the [current Node]
				- update scores
				- resort open list

- stop search if
	- insert the target Node into the 'closed' list
		- (solution has been found)

	- the 'open' list is empty, and the target Node has not been found
		- (no solution exists)

*/
