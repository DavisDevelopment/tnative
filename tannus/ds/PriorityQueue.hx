package tannus.ds;

class PriorityQueue<T> {
	/* Constructor Function */
	public function new(c : Comparator<T>):Void {
		content = new Array();
		sorted = false;
		comparator = c;
	}

/* === Instance Methods === */

	public function push(v : T):Void {
		content.push( v );
		sorted = false;
	}

	public function peek(?index : Int):Null<T> {
		if ( !sorted ) {
			sort();
		}
		if (index == null) {
			index = (content.length - 1);
		}
		return content[index];
	}

	public function pop():Null<T> {
		if ( !sorted ) {
			sort();
		}
		return content.pop();
	}

	public function map<O>(f : T -> O):Array<O> {
		return content.map( f );
	}

/* === Computed Instance Fields === */

	public var length(get, never):Int;
	private inline function get_length():Int return content.length;

/* === Instance Fields === */

	private var content : Array<T>;
	private var sorted : Bool;
	private var comparator : Comparator<T>;
}

private typedef Comparator<T> = T -> T -> Int;
