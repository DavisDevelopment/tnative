package tannus.chrome;

import tannus.ds.Promise;
import tannus.ds.promises.*;

@:forward
abstract Bookmark (BookmarkTreeNode) from BookmarkTreeNode {
	/* Constructor Function */
	public function new(tn : BookmarkTreeNode):Void {
		this = tn;
	}

/* === Instance Methods === */

	/**
	  * Append a child Bookmark to [this] one
	  */
	public function addChild(cd:BookmarkCreateData):Promise<Bookmark> {
		cd.parentId = this.id;
		return Promise.create({
			Bookmarks.create(cd).then(function(child) {
				return child;
			});
		});
	}

	/**
	  * Get all children
	  */
	public function children():ArrayPromise<Bookmark> {
		return Bookmarks.getSubTree(this.id);
	}

	/**
	  * Get a child by name
	  */
	public function find(name : String):Null<Bookmark> {
		if (this.children != null) {
			for (c in this.children)
				if (c.title == name)
					return new Bookmark(c);
			return null;
		} else return null;
	}

	/**
	  * Get child of [this] Bookmark by index
	  */
	public function child(index : Int):Null<Bookmark> {
		if (this.children == null)
			return null;
		else
			return new Bookmark(this.children[index]);
	}
}

typedef BookmarkTreeNode = {
	id : String,
	title : String,
	?parentId : String,
	?index : Int,
	?url : String,
	?dateAdded : Float,
	?children : Array<BookmarkTreeNode>
};

typedef BookmarkCreateData = {
	?parentId : String,
	?index : Int,
	?title : String,
	?url : String
};
