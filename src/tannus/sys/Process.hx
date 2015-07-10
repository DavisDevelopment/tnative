package tannus.sys;

import tannus.sys.Path;
import tannus.sys.IProcess;
import tannus.io.Signal;
import tannus.io.ByteArray;
import tannus.ds.Object;

@:forward
abstract Process (IProcess) {
	/* Constructor Function */
	public inline function new(cmd:String, args:Array<String>, ?opts:Object):Void {
		#if node

			this = new tannus.sys.node.NodeProcess(cmd, args, opts);
		
		#elseif python
		
			this = new tannus.sys.py.PyProcess(cmd, args, opts);

		#elseif (js && !node)

			#error
		
		#else

			this = new tannus.sys.NativeProcess(cmd, args, opts);

		#end
	}
}
