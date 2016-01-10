package tannus.ds;

import tannus.io.VoidSignal;
import tannus.ds.Async;

class Task {
	/* Constructor Function */
	public function new():Void {
		_doing = false;
		onkill = new VoidSignal();
		onfinish = new VoidSignal();
	}
	
/* === Instance Methods === */

	/* start [this] Task */
	public function start():Void {
		if ( !doing ) {
			_doing = true;
		}
		else {
			throw 'Error: Task already running';
		}
	}
	
	/* perform [this] Task */
	public function perform(done : Void->Void):Void {
		start();
		onfinish.once( done );
		action( finish );
	}
	
	/* the primary 'action' for [this] Task */
	private function action(done : Void->Void):Void {
		done();
	}
	
	/* mark [this] Task as 'finished' */
	private function finish():Void {
		_doing = false;
		onfinish.call();
	}
	
	/* abort [this] Task */
	public function abort():Void {
		if ( doing ) {
			onkill.call();
			_doing = false;
		}
		else {
			throw 'Error: Cannot abort a Task that is not running!';
		}
	}
	
	/* convert [this] Task to an Async */
	public function toAsync():Async {
		return perform.bind( _ );
	}
	
/* === Instance Fields === */

	private var _doing : Bool;
	public var doing(get, never):Bool;
	private inline function get_doing() return _doing;
	
	private var onkill : VoidSignal;
	private var onfinish : VoidSignal;
}
