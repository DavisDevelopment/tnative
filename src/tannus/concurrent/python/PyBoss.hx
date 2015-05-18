package tannus.concurrent.python;

import tannus.concurrent.IBoss;
import tannus.concurrent.python.Pipes;
import tannus.concurrent.python.Timer;
import tannus.concurrent.python.Multip;
import tannus.concurrent.python.Multip.Process;
import tannus.concurrent.python.Multip.Connection;

class PyBoss<I, O> implements IBoss<I, O> {
	public function new(wrkr : Class<PyWorker>):Void {
		worker = Type.createInstance(wrkr, []);
		var t = Multip.Pipe(true);
		sender = t._1;
		receiver = t._2;
		onres = null;
		process = new Process(null, worker._process, null, [receiver]);
		process.start();

		Pipes.add(sender, function(data:Dynamic) {
			if (onres != null)
				onres(cast data);
		});
	}

	public function send(data:I, ?cb:O->Void):Void {
		if (cb != null)
			onres = cb;

		sender.send( data );
	}

/* === Instance Fields === */
	public var worker:PyWorker;
	public var process:Process;
	private var sender:Connection;
	private var receiver:Connection;
	private var onres:Null<O->Void>;

/* === Initialize Stuff === */

	public static function __init__():Void {
		function pol() {
			var es = Pipes.poll();
			for (e in es) {
				while (e.con.poll()) {
					e.fn(e.con.recv());
				}
			}
		}

		var t = new Timer(0.25, pol);
		t.start();
	}
}
