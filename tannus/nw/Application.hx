package tannus.nw;

import tannus.sys.Application in NApp;
import tannus.nw.App;
import tannus.nw.Window in NWin;
import tannus.html.Win;
import tannus.ds.Obj;

import tannus.node.Buffer;
import tannus.io.ByteArray;

class Application extends NApp {
	/* Constructor Function */
	public function new():Void {
		super();

		appwin = NWin.get();
		argv = App.argv;
		manifest = Obj.fromDynamic( App.manifest );
	}

/* === Instance Methods === */

	/**
	  * clear the cache
	  */
	public inline function clearCache():Void {
		App.clearCache();
	}

	/**
	  * close all windows
	  */
	public inline function closeAllWindows():Void {
		App.closeAllWindows();
	}

/* === Computed Instance Fields === */

	public var win(get, never):Win;
	private inline function get_win():Win return appwin.window;

/* === Instance Fields === */

	public var appwin : NWin;
	public var manifest : Obj;
}
