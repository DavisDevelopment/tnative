package tannus.ds;

import tannus.io.Signal;

import tannus.ds.ProgressiveTask;

class StandardTask<Status, Result> extends ProgressiveTask {
	/* Constructor FUnction */
	public function new():Void {
		super();

		statusChange = new Signal();
		resultChange = new Signal();
		_res = null;
		_status = null;
	}

/* === Computed Instance Fields === */

	/* the current status of [this] Task */
	public var status(get, set):Null<Status>;
	private function get_status():Null<Status> return _status;
	private function set_status(v : Null<Status>):Null<Status> {
		var change:Delta<Status> = new Delta(v, status);
		var r = (_status = v);
		statusChange.call( change );
		return r;
	}

	/* the result of [this] Task */
	public var result(get, set):Null<Result>;
	private function get_result():Null<Result> return _res;
	private function set_result(v : Null<Result>):Null<Result> {
		var change:Delta<Result> = new Delta(v, _res);
		var r = (_res = v);
		resultChange.call( change );
		return r;
	}

/* === Instance Fields === */

	/* the result of [this] Task */
	private var _res : Null<Result>;

	/* the current status of [this] Task */
	private var _status : Null<Status>;

	/* Signal fired when [status] changes */
	public var statusChange : Signal<Delta<Status>>;

	/* Signal fired when [result] changes */
	public var resultChange : Signal<Delta<Result>>;
}
