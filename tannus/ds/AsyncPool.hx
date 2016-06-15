package tannus.ds;

import tannus.ds.AsyncStack;
import tannus.ds.Async.Async1;
import tannus.io.Signal;

using Lambda;
using tannus.ds.ArrayTools;
using haxe.ds.ArraySort;

class AsyncPool<T> {
	/* Constructor Function */
	public function new():Void {
		tasks = new Array();
		results = new Array();
		_done = new Signal();
	}

/* === Instance Methods === */

	/**
	  * Add a Task to [this] Pool
	  */
	public function push(task : Async1<T>):Void {
		var t = {
			index: 0,
			task: task
		};
		t.index = tasks.push( t );
	}

	/**
	  * The callback that is provided to all tasks in [this] Pool
	  */
	private function taskDone(task:Task<T>, error:Null<Dynamic>, result:Null<T>):Void {
		results.push({
			task: task,
			error: error,
			value: result
		});

		if (results.length == tasks.length) {
			complete();
		}
	}

	/**
	  * all Tasks have completed
	  */
	private function complete():Void {
		var reslist:Array<Result<T>> = new Array();
		results.macsort(left.task.index - right.task.index);
		reslist = results.macmap({
			error: _.error,
			value: _.value
		});
		_done.broadcast( reslist );
	}

	/**
	  * Start [this] Pool
	  */
	public function run(callback : Array<Result<T>> -> Void):Void {
		_done.once( callback );

		for (task in tasks) {
			task.task(task.index, taskDone.bind(task, _, _));
		}
	}

/* === Instance Fields === */

	private var tasks : Array<Task<T>>;
	private var results : Array<IResult<T>>;
	private var _done : Signal<Array<Result<T>>>;
}

private typedef Task<T> = {
	var index : Int;
	var task : Async1<T>;
};

private typedef Result<T> = {
	var error : Null<Dynamic>;
	var value : Null<T>;
};

private typedef IResult<T> = {
	>Result<T>,
	var task : Task<T>;
};
