package tannus.nw;

import tannus.ds.Object;

@:jsRequire('nw.gui', 'Window')
extern class Window {
	static function get(?window : tannus.html.Win):Window;
	static function open(url:String, ?options:Object):Window;

	var window : tannus.html.Win;
	var x : Float;
	var y : Float;
	var width : Float;
	var height : Float;
	var title : String;
	var menu : Dynamic;
	var isFullscreen : Bool;

	function moveTo(x:Float, y:Float):Void;
	function moveBy(x:Float, y:Float):Void;
	function resizeTo(x:Float, y:Float):Void;
	function resizeBy(x:Float, y:Float):Void;

	function focus():Void;
	function blur():Void;
	function show():Void;
	function hide():Void;
	function close(?force : Bool):Void;
	function reload():Void;
	function maximize():Void;
	function unmaximize():Void;
	function minimize():Void;
	function restore():Void;
	function toggleFullscreen():Void;
	function enterFullscreen():Void;
	function leaveFullscreen():Void;
	
	function setResizable(resizable : Bool):Void;
	function setAlwaysOnTop(top : Bool):Void;
	function showDevTools():Void;
	function closeDevTools():Void;
	function isDevToolsOpen():Bool;
}

private typedef WindowOptions = {
	?title:String,
	?icon:String,
	?toolbar:Bool,
	?frame:Bool,
	?width:Float,
	?height:Float,
	?position:String,
	?min_width:Float,
	?min_height:Float,
	?max_width:Float,
	?max_height:Float,
	?resizable:Bool,
	?fullscreen:Bool
};
