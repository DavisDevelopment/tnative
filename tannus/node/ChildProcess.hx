package tannus.node;

import haxe.Constraints.Function;

@:jsRequire('child_process')
extern class ChildProcess extends EventEmitter {
	function kill(?signal:String):Void;
	function disconnect():Void;
	function send(message:Dynamic, callback:Function):Void;

	var connected:Bool;

	static function exec(cmd:String, options:Dynamic, callback:Null<Dynamic>->Buffer->Buffer->Void):ChildProcess;
	static function execSync(cmd:String, ?opts:Dynamic):Buffer;
	static function form(modulePath:String, ?args:Array<String>, ?options:Dynamic):ChildProcess;
}
