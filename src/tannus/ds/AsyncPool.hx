package tannus.ds;

class AsyncPool<T> {
	/* Constructor Function */
	public function new():Void {
		tasks = new Array();
	}

	/* === Instance Methods === */

	/**
	 * Add a Task to the List
	 */
	public function push(t : Callback<T>->Void):Void {
		tasks.push({
			'index': tasks.length,
			'func' : t
		});
	}

	/**
	 * Do the stuff
	 */
	private function step(value:T, task:Task<T>, cb:Array<T>->Void):Void {
		results.push({
			'creator': task,
		'value': value
		});

		if (results.length == tasks.length) {
			/* sort the results by index */
			haxe.ds.ArraySort.sort(results, function(a, b) {
				return (a.creator.index - b.creator.index);
			});

			//- invoke the callback with the values of the results
			cb([for (r in results) r.value]);
			results = null;
		}
	}

	/**
	 * Run [this] Pool
	 */
	public function run(cb : Array<T>->Void):Void {
		var s = step.bind(_, _, cb);
		results = new Array();

		for (t in tasks) {
			t.func(s.bind(_, t));
		}
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
