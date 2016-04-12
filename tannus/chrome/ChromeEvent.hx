package tannus.chrome;

import haxe.Constraints.Function;

@:native( 'chrome.events.Event' )
extern class ChromeEvent<T:Function> {
	function addListener(f : T):Void;
	function removeListener(f : T):Void;
	function hasListener(f : T):Void;
	function hasListeners():Bool;
}
