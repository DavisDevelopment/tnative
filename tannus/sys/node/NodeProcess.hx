package tannus.sys.node;

import tannus.node.Buffer;
import tannus.sys.IProcess;
import tannus.sys.node.NodeNativeProcess;
import tannus.sys.node.NodeNativeProcess.NodeChildProcess;

import tannus.io.ByteArray;
import tannus.io.Signal;
import tannus.sys.Path;
import tannus.ds.Object;

class NodeProcess implements IProcess {
	/* Constructor Function */
	public function new(cmd:String, argset:Array<String>, ?opts:Object):Void {
		if (opts == null)
			opts = new Object({});

		complete = new Signal();
		output = new ByteArray();
		input = cast (opts['input'] || new ByteArray());
		env = cast (opts['env'] || new Map<String, String>());
		cwd = ((opts['cwd'].or('')) + '');

		command = cmd;
		args = argset;

		complete.once(function(x) {
			ready = true;
		});

		__init();
	}

/* === Instance Methods === */

	/**
	  * Initialize [this] Process
	  */
	private inline function __init():Void {
		/* Create the child-process */
		var nat = NodeChildProcess.spawn(command, args, {
			'cwd' : cwd,
		    	'env' : Object.fromMap( env )
		});

		/* Obtain it's 'pid' field */
		pid = nat.pid;

		/* Give the child-process it's input, if any */
		if (input.length > 0) {
			nat.stdin.write(input.toNodeBuffer());
		}

		/* Listen for data from the child-process */
		nat.stdout.on('data', function(rawData : Buffer) {
			//- Convert the data to a ByteArray
			var chunk:ByteArray = ByteArray.fromNodeBuffer(rawData);

			//- Append it to 'output'
			output.write( chunk );
		});

		/* Wait until the child-process has completed */
		nat.on('close', function(e : Dynamic) {
			complete.call(null);
		});
	}

	/**
	  * Await the completion of [this] Process
	  */
	public function await(cb:Void->Void):Void {
		if (!ready)
			complete.once(function(e) cb());
		else
			cb();
	}

/* === Instance Fields === */

	/* The Signal fired when [this] Process is complete */
	public var complete : Signal<Dynamic>;

	/* The output of the Process */
	public var output : ByteArray;

	/* The input to provide to the Process */
	public var input : ByteArray;

	/* The cwd to start the Process in */
	public var cwd : Path;

	/* An Object of environment variables to provide the Process with */
	public var env : Map<String, String>;

	/* The PID of [this] Process */
	public var pid : Int;

	/* The command to execute */
	private var command : String;

	/* The arguments to pass to the command */
	private var args : Array<String>;

	private var ready : Bool = false;
}
