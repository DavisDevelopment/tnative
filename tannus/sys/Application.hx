package tannus.sys;

import haxe.io.Input;
import haxe.io.Output;

import tannus.sys.Path;
import tannus.io.Prompt;
import tannus.TSys in Sys;

using StringTools;
using Lambda;
using tannus.ds.ArrayTools;
using tannus.ds.StringUtils;

class Application {
	/* Constructor Function */
	public function new():Void {
		environment = Sys.environment();
		argv = Sys.args();
		executable = Sys.executablePath();
	}

	/* === Instance Methods === */

	/* terminate [this] Application */
	public function exit(code:Int = 0):Void {
		Sys.exit( code );
	}

	/* create a prompt */
	public function prompt(msg:String, ?cb:String->Void):Prompt {
		var p:Prompt = new Prompt( msg );
		if (cb != null) {
			p.getLine( cb );
		}
		return p;
	}

	/**
	  * Print some data to the console
	  */
	public inline function print(x : Dynamic):Void {
		Sys.print( x );
	}

	/**
	  * Print some data, followed by a newline, to the console
	  */
	public inline function println(x : Dynamic):Void {
		Sys.println( x );
	}

	/* 'main' method of [this] Application */
	public function start():Void {
		null;
	}

	/* === Computed Instance Fields === */

	/* the current working directory */
	public var cwd(get, set):Path;
	private function get_cwd():Path {
		return Sys.getCwd();
	}
	private function set_cwd(v : Path):Path {
		Sys.setCwd( v );
		return cwd;
	}

	/* === Instance Fields === */

	/* the Path to the executable */
	public var executable : Path;

	/* map of all environment variables */
	public var environment : Map<String, String>;

	/* array of all command-line arguments */
	public var argv : Array<String>;
}
