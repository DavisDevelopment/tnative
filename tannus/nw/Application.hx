package tannus.nw;

import tannus.sys.Application in NApp;
import tannus.nw.App;
import tannus.nw.Window in NWin;
import tannus.html.Win;
import tannus.ds.Obj;

import tannus.node.Buffer;
import tannus.io.ByteArray;
import tannus.io.impl.JavaScriptBinary;

class Application extends NApp {
	/* Constructor Function */
	public function new():Void {
		super();

		appwin = NWin.get();
		argv = App.argv;
		manifest = Obj.fromDynamic( App.manifest );

		trace( App.dataPath );
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

	/**
	  * execute a shell command, and get the output
	  */
	public function system(command:String, ?options:SystemOptions):ByteArray {
		var opts:Dynamic = {};
		if (options != null) {
			opts.cwd = options.cwd;
			opts.input = (options.input != null ? cast(options.input, JavaScriptBinary).toBuffer() : null);
			opts.env = options.env;
			opts.shell = options.shell;
		}
		var buffr = tannus.node.ChildProcess.execSync(command, opts);
		return cast JavaScriptBinary.fromBuffer( buffr );
	}

/* === Computed Instance Fields === */

	public var win(get, never):Win;
	private inline function get_win():Win return appwin.window;

/* === Instance Fields === */

	public var appwin : NWin;
	public var manifest : Obj;
}

private typedef SystemOptions = {
	?cwd : String,
	?input : ByteArray,
	?env : Dynamic,
	?shell : String
};
