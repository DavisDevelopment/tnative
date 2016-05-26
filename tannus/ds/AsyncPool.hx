package tannus.ds;

import tannus.ds.AsyncStack;

class AsyncPool<T> {
	/* Constructor Function */
	public function new():Void {
		tasks = new Array();
	}

	/* === Instance Methods === */

	/**
	 * Add a Task to the List
	 */
	public function push(t : Callback<T> -> Void):Void {
		tasks.push({
			'index': tasks.length,
			'func' : t
		});
	}

	/**
	  * build an async-stack from [this]
	  */
	private function pack():AsyncStack {
		var stack = new AsyncStack();
		for (t in tasks) {
			stack.push(function( next ) {
				t.func(function(value) {
					results.push({
						'creator': t,
						'value': value
					});
					next();
				});
			});
		}
		return stack;
	}

	/**
	 * Run [this] Pool
	 */
	public function run(cb : Array<T> -> Void):Void {
		results = new Array();
		var stack:AsyncStack = pack();
		stack.run(function() {
			haxe.ds.ArraySort.sort(results, function(l, r) {
				return (l.creator.index - r.creator.index);
			});
			var values = new Array();
			for (r in results) {
				values.push( r.value );
			}

			cb( values );
		});
	}

	/* === Instance Fields === */

	private var tasks : Array<Task<T>>;
	private var results : Array<Result<T>>;
}

private typedef Callback<T> = T -> Void;
private typedef Task<T> = {
	var index : Int;
	var func : Callback<T> -> Void;
};
private typedef Result<T> = {
	var creator : Task<T>;
	var value : T;
}
