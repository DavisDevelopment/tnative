package tannus.ds;

/**
  * Stack
  */
@:generic
class Stack<T> {
	/* Constructor Function */
	public function new(?dat:Array<T>):Void {
		data = (dat != null ? dat : new Array());
	}

/* === Instance Methods === */

	/**
	  * Look at the next item in the Stack
	  */
	public function peek():T {
		return (data[ 0 ]);
	}

	/**
	  * Get the next item in the Stack, removing it from the Stack
	  */
	public function pop():T {
		return (data.shift());
	}

	/**
	  * Add an item to the Stack
	  */
	public function add(item : T):Void {
		data.unshift( item );
	}

	/**
	  * Test whether [this] Stack is empty
	  */
	public var empty(get, never):Bool;
	private inline function get_empty():Bool {
		return (data.length == 0);
	}

/* === Instance Fields === */

	/* the underlying Array */
	private var data : Array<T>;
}
