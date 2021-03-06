package tannus.ds;

import tannus.io.Signal;
import tannus.math.Percent;

import tannus.ds.ProgressiveTask;

class StandardTask<Status, Result> extends ProgressiveTask {
	/* Constructor FUnction */
	public function new():Void {
		super();

		statusChange = new Signal();
		resultChange = new Signal();
		failureEvent = new Signal();
		_res = null;
		_status = null;
	}

/* === Instance Methods === */

    /**
      * report an error that caused the Task to fail
      */
    public function fail(error : Dynamic):Void {
        failureEvent.call( error );
    }

    /**
      * link another Task to [this] one as a subtask
      * [child_percentage] is the percentage of [this] Task that [child] accounts for
      */
    public function link(child:StandardTask<Status,Dynamic>, child_percentage:Percent):Void {
        var total:Float = child_percentage;
        child.onProgress.on(function(delta) {
            if (delta.current.exists && delta.previous.exists) {
                var dif:Float = (delta.current.value - delta.previous.value);
                var step:Percent = new Percent( dif );
                step = new Percent(step.of( total ));
                progress( step );
            }
        });
        child.statusChange.on(function(d) {
            status = d.current;
        });
        //child.onfinish.once(function() {
            //progress( child_percentage );
        //});
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

	/* Signal fired when an error occurs */
	public var failureEvent : Signal<Dynamic>;
}
