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
		#elseif js
		    return [];
		#else
			return NSys.args();
		#end
	}

	/**
	  * Prints some data to the console
	  */
	public static inline function print(x : Dynamic):Void {
		#if node
			(untyped __js__('process.stdout.write'))(Std.string( x ));
        #elseif js
            return ;
		#else
			NSys.print( x );
		#end
	}

	/**
	  * Prints some data, followed by a newline, to the console
	  */
	public static inline function println(x : Dynamic):Void {
		#if node
			print(Std.string(x) + '\n');
        #elseif js
            return ;
		#else
			NSys.println( x );
		#end
	}

	/**
	  * Gets the Path to the current executable
	  */
	public static inline function executablePath():Path {
		#if node_webkit
			return Std.string(untyped __js__('process.execPath'));
		#elseif node	
			return Std.string(untyped __js__('__filename'));
        #elseif js
            return new Path('');
		#else
			return NSys.programPath();
		#end
	}

	/**
	  * Gets the CWD as a Path
	  */
	public static inline function getCwd():Path {
		#if node
			return Std.string(untyped __js__('process.cwd()'));
        #elseif js
            return new Path('');
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
        #elseif js
            return ;
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
        #elseif js
            return new Map();
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
        #elseif js
            return '';
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
        #elseif js
            return ;
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
		return (getEnv('HOME')+'/tmp/');
	}

	/**
	  * get the system on which we are running
	  */
	public static function systemName():String {
	    #if node
	        var nt:String = tannus.node.Os.type();
	        if (nt == 'Windows_NT') {
	            nt = 'Windows';
	        }
	        return nt;
        #elseif js
            return 'Browser';
	    #else
	        return Sys.systemName();
	    #end
	}
}

