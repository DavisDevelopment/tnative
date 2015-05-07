package tannus.concurrent.js;

import tannus.concurrent.js.JSBoss;
import tannus.io.ByteArray;
import tannus.io.Ptr;
import tannus.io.Getter;
import tannus.ds.Maybe;
import tannus.sys.Path;

#if macro

import tannus.sys.File;
import tannus.internal.CompileTime;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Compiler;
import tannus.concurrent.js.WorkerBuildTools;

#end

using StringTools;
using haxe.macro.ExprTools;

class Workers {
/*
   ==== Static Methods ==== 
*/

	/**
	  * Compile and Cache a new Worker (if you don't have it cached already), and return a Boss Reference to it
	  -----
	  * @param [cl]{Class<JSWorker>} - An expression of a reference to the Class which will power the worker
	  * @param [bd]{String} - A Path to the directory you wish to have all Worker scripts placed in
	  */
	public static macro function create<I, O>(cl:Expr, bd:String):ExprOf<JSBoss<I, O>> {
		var key:String = cl.toString();

		if (built.exists(key)) {
			var url:ExprOf<String> = CompileTime.toExpr(built[key]);
			return macro new tannus.concurrent.js.JSBoss($url);
		} else {
			var file:Path = (new Path(cl.toString().replace('.', '/')).name);
			file.extension = 'js';
			var fp:String = (bd + file);

			var workerFile:File = generate((cl.toString()), fp);
			var url:String = (workerFile.path.directory.name + '/' + workerFile.path.name);
			built[key] = url;
			var eurl:ExprOf<String> = CompileTime.toExpr(url);

			return macro new tannus.concurrent.js.JSBoss($eurl);
		}
	}

#if macro
	/**
	  *  "register a sub-class of JSWorker for employment"
	  =====================
	  * This will, using macro-magic, generate a separate application, store it
	  * inline as a ByteArray, and load that ByteArray as a JavaScript file via
	  * dataURI, executing it as a Web Worker
	  */
	public static function generate(cl:String, buildPath:String):File {
		var fn:String = (cl.toString().replace('.', '/') + '.hx');
		var buildFile:File = workorBuildFile((cl + ''), buildPath);

		var _cwd:String = Sys.getCwd();
		Sys.setCwd( buildFile.path.directory );
		Sys.command('haxe-nightly', [buildFile.path]);

		var resultFile:File = buildPath;
		resultFile.rename(_cwd + buildPath);

		buildFile.delete();
		Sys.setCwd(_cwd);

		return resultFile;
	}

	/**
	  * Load the '_build.hxml' Template File
	  */
	public static function loadBuildFile():String {
		return (new File('tnative/src/tannus/concurrent/_build.tmpl')).read();
	}

	/**
	  * Generate a build file from the Template, and return it as a File
	  */
	public static function workorBuildFile(pathToWorkorClass:String, targetBuildPath:String):File {
		var data:String = (loadBuildFile().replace('{{path-to-class}}', pathToWorkorClass));
		data = data.replace('{{temp-path}}', targetBuildPath);

		var buildFileName:Path = ('tnative/src/tannus/concurrent/js/build'+[for (x in 0...6) (Std.int(Math.random() * 9))].join('')+'.hxml');
		buildFileName = (Sys.getCwd() + buildFileName);

		var buildFile:File = (buildFileName);
		buildFile.write( data );

		return buildFile;
	}
	
#end

	/* The Worker Registry */
	public static var _registry:Map<String, Getter<ByteArray>> = {new Map();};

	private static var built:Map<String, String> = {new Map();};
}

#if macro
private typedef F = tannus.sys.FileSystem;
#end
