package tannus.ds;

using Lambda;
using tannus.ds.ArrayTools;

class TreeNode {
	/* Constructor Function */
	public function new():Void {
		parentNode = null;
		childNodes = new Array();
	}

/* === Instance Methods === */

	/**
	  * Add [child] as a sub-Node of [this] Node
	  */
	public function append(child : TreeNode):Void {
		if (!childNodes.has( child )) {
			child.parentNode = this;
			childNodes.push( this );
		}
	}

	/**
	  * Remove [child] from [this] Node
	  */
	public function removeChild(child : TreeNode):Void {
		if (childNodes.has( child )) {
			child.parentNode = null;
			childNodes.remove( child );
		}
	}

/* === Instance Fields === */

	public var parentNode : Null<TreeNode>;
	public var childNodes : Array<TreeNode>;
}
