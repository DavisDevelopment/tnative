package tannus.nw;

import tannus.ds.Object;
import tannus.node.EventEmitter;

import haxe.Constraints.Function;

@:jsRequire('nw.gui', 'App')
extern class App {
	static var argv:Array<String>;
	static var fullArgv:Array<String>;
	static var dataPath:String;
	static var manifest:Object;

	static function clearCache():Void;
	static function closeAllWindows():Void;
	static function crashBrowser():Void;
	static function crashRenderer():Void;

	static function on(s:String, f:Function):Void;
	static function once(s:String, f:Function):Void;
	static function removeListener(s:String, f:Function):Void;
}
