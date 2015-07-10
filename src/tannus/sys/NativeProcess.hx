package tannus.sys;

import tannus.sys.IProcess;
import tannus.sys.Path;
import tannus.io.ByteArray;
import tannus.io.Signal;
import tannus.ds.Object;

import Std.string in str;
import Std.is;

class NativeProcess implements IProcess {
	/* Constructor Function */
	public function new(cmd:String, argset:Array<String>, ?opts:Object):Void {
		if (opts == null)
			opts = new Object({});

		/* Declare Default Values for Instance Fields */
		complete = new Signal();
		output = new ByteArray();
		input = new ByteArray();
		cwd = '~/';
		env = new Map();
		command = cmd;
		args = argset;

		/* Get [cwd] when provided */
		if (opts['cwd'].exists)
			cwd = str(opts['cwd']);

		/* Get [input] when provided */
		if (opts['input'].exists) {
			var uin:String = str(opts['input']);
			input.write( uin );
		}

		/* Get [env] when provided */
		if (opts['env'].exists) {
			env = cast (opts['env'].or(new Map<String, String>()));
		}

		/* The first time [complete] fires, mark [this] Process as 'ready' */
		complete.once(function(e) {
			ready = true;
		});

		__init();
	}

/* === Instance Methods === */

	/**
	  * Initialize [this] Process
	  */
	private function __init():Void {
		//- remember the current-working-directory
		var ocwd:Path = Sys.getCwd();

		//- remember the current environment-variables
		var oenv:Object = Object.fromMap(Sys.environment());

		//- move to [cwd]
		Sys.setCwd( cwd );

		//- map [env] onto the environment variables
		for (key in env.keys()) {
			Sys.putEnv(key, env[key]);
		}

		//- Create the underlying child-process
		var cp = new sys.io.Process(command, args);

		//- Get [pid]
		pid = cp.getPid();

		/* If [input] was provided, give it to [cp] */
		if (input.length > 0)
			cp.stdin.write( input );
		
		//- Get the output of [cp]
		var nout = cp.stdout.readAll();
		output.write( nout );

		/* If any errors were reported, throw them */
		/*
		var nerr = cp.stderr.readAll();
		if (nerr.length > 0) {
			throw nerr.toString();
		}
		*/

		/* restore the environment variables back to their original state */

		//- Nullify all variables which were set by [env]
		for (key in env.keys())
			Sys.putEnv(key, '');

		//- Reassign all variables which were present before [env] was mapped
		for (key in oenv.keys)
			Sys.putEnv(key, oenv[key]);

		/* move back to the original working-directory */
		Sys.setCwd( ocwd );

		complete.call( null );
	}

	/**
	  * Wait for [this] Process to complete
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
	public var cwd:Path;
	public var pid:Int;
	public var env:Map<String, String>;
	
	private var command:String;
	private var args:Array<String>;
	private var ready:Bool = false;
}
