package tannus.concurrent;

import tannus.concurrent.JSBoss;
import tannus.io.ByteArray;
import tannus.io.Ptr;
import tannus.io.Getter;
import tannus.ds.Maybe;

#if macro

import tannus.sys.File;
import tannus.sys.Path;
import tannus.internal.CompileTime;

import haxe.macro.Context;

#end

using StringTools;

class Workers {
/*
   ==== Static Methods ==== 
*/

	/**
	  *  "register a sub-class of JSWorker for employment"
	  =====================
	  * This will, using macro-magic, generate a separate application, store it
	  * inline as a ByteArray, and load that ByteArray as a JavaScript file via
	  * dataURI, executing it as a Web Worker
	  */
	public static macro function register(loadingParams : Array<String>) {
		var lp = loadingParams.copy();
		var ptw:String = lp.shift(), tbp:String = lp.shift();

		var build_file:File = workorBuildFile(ptw, tbp);

		try {

			Sys.setCwd('tannus/concurrent/');
			Sys.command('haxe-nightly', [build_file.path]);
		} catch (err : String) {
			
			build_file.delete();
		}
		
		//- Compiled JavaScript File
		var cf:File = tbp;
		if (cf.exists) {
			var code:ByteArray = cf.read();
			
			if (!code.empty) {
				trace('Deleting ${build_file.path}..');
				build_file.delete();

				trace('Deleting ${cf.path}..');
				cf.delete();
				
				#if debug
				(new File(Std.string(cf.path) + '.map')).delete();
				#end
			}

			var s:String = (haxe.Serializer.run(code.toBytes()));
			// Context.makeExpr(s, Context.currentPos());
			var name:String = (ptw.split('.').pop());

			return macro (function() {
				var _cp:String = $v{ptw};
				var bits:Array<String> = _cp.split('.');

				var reg:Map<String, tannus.io.Getter<tannus.io.ByteArray>> = tannus.concurrent.Workers._registry;

				var wnam:String = bits.pop();
				if (reg.exists(wnam)) {
					if (reg.exists(_cp)) {
						return reg[_cp];
					} 
					else {
						var registered:Bool = reg.exists(wnam);

						while (registered) {
							wnam = (bits.pop() + '.' + wnam);

							registered = reg.exists( wnam );
						}
					}
				}
				
				var _data:tannus.ds.Maybe<tannus.io.ByteArray> = null;

				var dat:tannus.io.Getter<tannus.io.ByteArray> = function() {
					return (_data = (_data || haxe.Unserializer.run($v{s})));
				};
				trace( dat() );

				var _g:tannus.io.Getter<tannus.io.ByteArray> = (dat);

				reg[wnam] = _g;
				return _g;
			}());
		}

		else {
			return Context.error('No File found at "$tbp", perhaps the build failed?', Context.currentPos());
		}
	}


#if macro
	
	/**
	  * Load the '_build.hxml' Template File
	  */
	public static function loadBuildFile():String {
		return (new File('tannus/concurrent/_build.hxml')).read();
	}

	/**
	  * Generate a build file from the Template, and return it as a File
	  */
	public static function workorBuildFile(pathToWorkorClass:String, targetBuildPath:String):File {
		var data:String = (loadBuildFile().replace('{{path-to-class}}', pathToWorkorClass));
		data = data.replace('{{temp-path}}', targetBuildPath);

		var buildFileName:Path = ('tannus/concurrent/build'+[for (x in 0...6) (Std.int(Math.random() * 9))].join('')+'.hxml');
		buildFileName = (Sys.getCwd() + buildFileName);

		var buildFile:File = (buildFileName);
		buildFile.write( data );

		return buildFile;
	}
	
#end

	/* The Worker Registry */
	public static var _registry:Map<String, Getter<ByteArray>> = {new Map();};
}

#if macro
private typedef F = tannus.sys.FileSystem;
#end
