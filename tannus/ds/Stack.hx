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
	public function peek(d:Int = 0):T {
		return (data[ d ]);
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
	  * Add an item to the end of [this] Stack
	  */
	public function under(item : T):Void {
		data.push( item );
	}
	
	/**
	  * get/remove the last item in [this] Stack
	  */
	public function bottom():T {
		return data.pop();
	}
	
	/**
	  * get/set the 'next' item in [this] Stack
	  */
	public function next(?item : T):T {
		if (item != null) {
			add( item );
		}
		else {
			item = pop();
		}
		return item;
	}
	
	/**
	  * get/set the 'last' item in [this] Stack
	  */
	public function last(?item : T):T {
		if (item != null) {
			under( item );
		}
		else {
			item = bottom();
		}
		return item;
	}

	/**
	  * Copy [this] Stack
	  */
	public function copy():Stack<T> {
		return new Stack(data.copy());
	}
	
	/**
	  * Iterate over [this] Stack
	  */
	public function iterator():StackIterator<T> {
		return new StackIterator( this );
	}

	/**
	  * Test whether [this] Stack is empty
	  */
	public var empty(get, never):Bool;
	private function get_empty():Bool {
		return (data.length == 0);
	}

/* === Instance Fields === */

	/* the underlying Array */
	private var data : Array<T>;
}

@:generic
private class StackIterator<T> {
	public function new(s : Stack<T>):Void {
		stack = s;
	}
	
	public function hasNext():Bool {
		return ( !stack.empty );
	}
	
	public function next():T {
		return stack.pop();
	}
	
	private var stack : Stack<T>;
}
