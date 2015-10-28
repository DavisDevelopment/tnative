package tannus.sys.node;

import tannus.node.EventEmitter;
import tannus.node.ReadableStream;
import tannus.node.WritableStream;
import tannus.ds.Object;

@:jsRequire('child_process', 'ChildProcess')
extern class NodeNativeProcess extends EventEmitter {
	/* STDIN for [this] Process */
	var stdin : WritableStream;

	/* STDOUT for [this] Process */
	var stdout : ReadableStream;

	/* STDERR for [this] Process */
	var stderr : ReadableStream;

	/* Process ID (PID) for [this] Process */
	var pid : Int;

	/* Method used to abort [this] Process */
	function kill(sig : String):Void;
}

@:jsRequire('child_process')
extern class NodeChildProcess {
	/**
	  * Spawn a sub-process
	  */
	static function spawn(cmd:String, args:Array<String>, options:Object):NodeNativeProcess;
}
