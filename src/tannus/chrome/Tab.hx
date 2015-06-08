package tannus.chrome;

import tannus.sys.Path;
import tannus.chrome.Windows;
import tannus.chrome.Tabs;
import tannus.ds.Object;

@:forward
abstract Tab (CTab) {
	/* Constructor Function */
	public inline function new(ct : CTab):Void {
		this = ct;
	}

/* === Instance Methods === */
	
	/**
	  * Update [this] Tab
	  */
	public inline function update(props:Object, ?cb:Tab->Void):Void {
		Tabs.update(this.id, props, function(t) {
			if (cb != null) {
				cb( t );
			}
		});
	}

	/**
	  * Reload [this] Tab
	  */
	public inline function reload(?bypassCache:Bool, ?cb:Void->Void):Void {
		var opts:Object = {};
		if (bypassCache != null)
			opts['bypassCache'] = bypassCache;
		Tabs.reload(this.id, opts, function(t) {
			if (cb != null) {
				cb();
			}
		});
	}

	/**
	  * Send data to [this] Tab
	  */
	public inline function sendMessage(data:Dynamic, ?onres:Dynamic->Void):Void {
		Tabs.lib.sendMessage(this.id, data, {}, onres);
	}

	/**
	  * Execute some JavaScript or CSS code in [this] Tab
	  */
	public inline function executeScript(path:Null<String>, code:Null<String>, ?cb:Void->Void):Void {
		Tabs.executeScript(this.id, path, code, cb);
	}
}

typedef CTab = {
	var id : Null<Int>;
	var index : Int;
	var windowId : Int;
	var openerTabId : Null<Int>;
	var selected : Bool;
	var highlighted : Bool;
	var active : Bool;
	var pinned : Bool;
	var url : Null<Path>;
	var title : Null<String>;
	var favIconUrl : Null<String>;
	var status : Null<String>;
	var incognito : Bool;
	var width : Null<Int>;
	var height : Null<Int>;
	var sessionId : Null<String>;
};
