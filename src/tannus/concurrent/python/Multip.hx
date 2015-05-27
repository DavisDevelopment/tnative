package tannus.concurrent.python;

import haxe.Constraints.Function;
import python.KwArgs;
import python.Tuple.Tuple2;

@:pythonImport('multiprocessing')
extern class Multip {
	static function Pipe(?duplex:Bool):Tuple2<Connection, Connection>;
}

@:pythonImport('multiprocessing', 'Process')
extern class Process {
	/* Constructor Function */
	function new(group:Dynamic, target:Function, name:Null<String>, args:Array<Dynamic>):Void;

	function start():Void;

	function join(?timeout:Int):Void;
}

@:pythonImport('multiprocessing', 'Connection')
extern class Connection {
	function send(data : Dynamic):Void;
	function recv():Dynamic;
	function close():Void;
	function poll(?timeout:Int):Bool;
}

@:pythonImport('multiprocessing', 'Queue')
extern class Queue {
	function new(?max_size:Int):Void;
	function qsize():Int;
	function empty():Bool;
	function full():Bool;
	function put(data : Dynamic):Void;
	function get():Dynamic;
	function close():Void;
}

@:pythonImport('multiprocessing', 'Lock')
extern class Lock {
	function new():Void;
	function acquire():Void;
	function release():Void;
}
