package tannus.concurrent.python;

import haxe.Constraints.Function;
import haxe.extern.Rest;

@:pythonImport('concurrent.futures', 'Executor')
extern class Executor {
	function new(max_threads:Int=1):Void;
	function submit(cb:Function, args:Rest<Dynamic>):Future;
	function shutdown(?wait:Bool):Void;
}

@:pythonImport('concurrent.futures', 'ThreadPoolExecutor')
extern class ThreadPoolExecutor extends Executor {}

@:pythonImport('concurrent.futures', 'ProcessPoolExecutor')
extern class ProcessPoolExecutor extends Executor {}

extern class Future {
	function cancel():Void;
	function cancelled():Bool;
	function running():Bool;
	function done():Bool;
	function result(?timeout:Int):Dynamic;
	function exception(?timeout:Int):Dynamic;
	function add_done_callback(fn : Future->Void):Void;
}
