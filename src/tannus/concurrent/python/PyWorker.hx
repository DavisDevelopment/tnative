package tannus.concurrent.python;

import tannus.concurrent.IWorker;

import tannus.concurrent.python.Multip;
import tannus.concurrent.python.Multip.Connection;

class PyWorker implements IWorker<Dynamic, Dynamic> {
	public function new():Void {}

	public function _process(rec : Connection):Void {
		var data:Dynamic = rec.recv();

		process(data, function(res : Dynamic) {
			rec.send( res );
		});
	}

	public function process(input:Dynamic, reply:Dynamic->Void):Void {
		return;
	}
}
