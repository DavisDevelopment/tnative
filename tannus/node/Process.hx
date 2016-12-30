package tannus.node;

import haxe.extern.EitherType in Either;
import haxe.extern.Rest;
import haxe.Constraints.Function;

@:native( 'Process' )
extern class Process extends EventEmitter {
/* === Instance Fields === */

	var arch : String;
	var argv : Array<String>;
	var connected : Bool;
	var env : Dynamic;
	var execArgv : Array<String>;
	var execPath : String;
	var exitCode : Int;
	var pid : Int;
	var platform : String;
	//var type : String;

/* === Instance Methods === */

	function abort() : Void;
	function chdir(dir:String):Void;
	function cwd():String;
	function disconnect():Void;
	function exit(code:Int):Void;
	function geteuid():String;
	function kill(pid:Int, ?signal:Either<String, Float>):Void;
	function nextTick(action:Function, args:Rest<Dynamic>):Void;
	function send(message:Dynamic, ?options:Dynamic, ?callback:Function):Bool;
	function seteuid(id : Either<String, Int>):Void;
	function type():String;
}
