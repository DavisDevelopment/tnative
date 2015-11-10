package tannus;

import tannus.sys.Path;
import tannus.io.Ptr;
import tannus.io.ByteArray;

import tannus.ds.Object;

import tannus.internal.NSys;
import tannus.Platform;

/**
  * Wrapper around Haxe's Sys class, and implementations of those methods which are possible in Node
  */
class TSys {
	/**
	  * Gets the list of arguments which were passed to this program
	  */
	public static inline function args():Array<String> {
		#if node
			var a:Array<String> = cast (untyped __js__('process.argv'));
			return a.slice(2);
		#else
			return NSys.args();
		#end
	}

	/**
	  * Gets the Path to the current executable
	  */
	public static inline function executablePath():Path {
		#if node
			return Std.string(untyped __js__('__filename'));
		#else
			return NSys.executablePath();
		#end
	}

	/**
	  * Gets the CWD as a Path
	  */
	public static inline function getCwd():Path {
		#if node
			return Std.string(untyped __js__('process.cwd()'));
		#else
			return NSys.getCwd();
		#end
	}

	/**
	  * Sets the CWD
	  */
	public static inline function setCwd(ncwd : String):Void {
		var _n:String = ncwd;
		#if node
			untyped __js__('process.chdir(_n)');
		#else
			NSys.setCwd(_n);
		#end
	}
	
	/**
	  * Get a Map of all environment variables
	  */
	public static function environment():Map<String, String> {
		#if node
			var node_env:Object = new Object(untyped __js__('process.env'));
			var result:Map<String, String> = cast node_env.toMap();
			return result;
		#else
			return NSys.environment();
		#end
	}

	/**
	  * Get the value of a particular environment variable
	  */
	public static function getEnv(vn : String):String {
		var _vn:String = vn;
		#if node
			return Std.string(untyped __js__('process.env[_vn]'));
		#else
			return NSys.getEnv(vn);
		#end
	}

	/**
	  * Set the value of an environment variable
	  */
	public static function putEnv(n:String, v:String):Void {
		var _n:String = n, _v:String = v;
		#if node
			untyped __js__('process.env[_n] = _v');
		#else
			NSys.putEnv(n, v);
		#end
	}

	/**
	  * Stop the current Process, with the given exit code
	  */
	public static inline function exit(ecode : Int):Void {
		var code:Int = ecode;
		#if node
			untyped __js__('process.exit(code)');
		#elseif js
			js.Browser.window.close();
		#else
			NSys.exit( ecode );
		#end
	}

	/**
	  * Get the temp-file directory
	  */
	public static inline function tempDir():Path {
		return '~/tmp/';
	}
}

