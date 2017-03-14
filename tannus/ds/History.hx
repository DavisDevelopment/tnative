package tannus.ds;

using Lambda;
using tannus.ds.ArrayTools;

class History<T> {
	/* Constructor Function */
	public function new():Void {
		stack = new Array();
	}

/* === Instance Methods === */

	/**
	  * Add a new entry
	  */
	public function add(entry : T):Void {
		if (!stack.empty() && compare(entry, stack.last())) {
			return ;
		}

		index = (stack.push( entry ) - 1);
	}

	/**
	  * Get the value of the [i]th entry from the top
	  */
	public function peek(i : Int = 0):Null<T> {
		//return stack[stack.length - (i + 1)];
		return stack[index - i];
	}

	/**
	  * Remove the top entry from the stack
	  */
	public function pop():Null<T> {
		var result = stack.pop();
		index--;
		return result;
	}

	/**
	  * Get the index of the given value in the stack
	  */
	private function find(value : T):Int {
		for (i in 0...stack.length) {
			if (compare(value, stack[i])) {
				return i;
			}
		}
		return -1;
	}

	/**
	  * Compare two values in [this]
	  */
	private function compare(x:T, y:T):Bool {
		return (x == y);
	}

/* === Instance Fields === */

	private var index : Int;
	private var stack : Array<T>;
}
