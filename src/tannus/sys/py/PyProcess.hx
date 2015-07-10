package tannus.sys.py;

import tannus.sys.IProcess;
import tannus.sys.Path;
import tannus.ds.Object;
import tannus.io.ByteArray;
import tannus.io.Signal;

import python.lib.subprocess.Popen;

class PyProcess implements IProcess {
	/* Constructor Function */
	public function new(cmd:String, argset:Array<String>, ?opts:Object):Void {
		if (opts == null)
			opts = new Object({});

		complete = new Signal();
		output = new ByteArray();
		input = new ByteArray();
		
		/* If 'input' was provided in the 'opts' Object, write that to [input] */
		if ( opts['input'] ) {
			var uinp:ByteArray = ByteArray.fromString(opts['input']);
			input.write( uinp );
		}

		env = cast opts['env'].or(new Map<String, String>());
		cwd = cast (opts['cwd'].or(''));

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
	private function __init():Void {
		/* Create the child-process */
		var oenv:Object = env;
		var sp = new Popen([command].concat(args), null, null, -1, -1, -1, null, null, null, (cwd!=''?cwd:null));
		pid = sp.pid;

		var data = sp.communicate(input);
		output.write( data._1 );

		complete.call( null );
	}

	/**
	  * Wait for the Process to complete
	  */
	public function await(cb : Void->Void):Void {
		if (!ready)
			complete.once(function(e) cb());
		else
			cb();
	}

/* === Instance Fields === */

	public var complete:Signal<Dynamic>;
	public var output:ByteArray;
	public var input:ByteArray;
	public var env:Map<String, String>;
	public var cwd:Path;
	public var pid:Int;

	private var command:String;
	private var args:Array<String>;
	private var ready:Bool = false;
}
