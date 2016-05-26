package tannus.concurrent;

import tannus.io.Byte;
import tannus.io.ByteArray;
import tannus.io.Ptr;
import tannus.io.Getter;
import tannus.sys.File;
import tannus.sys.Directory;
import tannus.sys.FileSystem in Fs;
import tannus.sys.Path;
import tannus.sys.Mimes;
import tannus.io.Blob;
import tannus.internal.BuildFile;
import tannus.internal.BuildData;
import tannus.format.hxml.*;

import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Format;

import haxe.Template;

using haxe.macro.ExprTools;
using StringTools;

class Workers {
	/**
	  * 'Hire' a Worker
	  */
	public static macro function hire(bf : String):ExprOf<tannus.concurrent.js.Boss> {
		var ebf = buildWorker( bf );

		return macro (new tannus.concurrent.js.Boss( $ebf ));
	}

	/**
	  * Build a Worker
	  */
	public static #if !macro macro #end function buildWorker(buildFile : String):ExprOf<Blob> {
		var buildf:BuildFile = loadBuildFile( buildFile );
		buildf.def( 'worker' );
		var bd:BuildData = buildf.getData()[0];
		
		var mainBuildPath:Path = getMainBuildPath();
		
		var mainClass:String = '';

		var _cwd:Path = Sys.getCwd();
		var _tdir:Path = mainBuildPath.directory;

		/* resolve the target-path for this build */
		bd.buildPath = (mainBuildPath.directory + bd.buildPath.name);
		if ( !bd.buildPath.absolute ) {
			bd.buildPath = _cwd.resolve( bd.buildPath ).absolutize();
		}
		
		//- alter the paths in the build-file to continue pointing to their intended location
		bd.classPaths = bd.classPaths.map(function(cp) {
			return (cp.absolute ? cp : (_cwd + cp)).normalize();
		});
		bd.classPaths.push( _cwd );
		mainClass = bd.mainClass;
		bd.mainClass = 'WorkerMain';
		var mcTemp:Template = buildWorkerMainTemplate( bd.classPaths );
		var mcFile:File = (_tdir + 'WorkerMain.hx');
		mcFile.write(mcTemp.execute({
			'mainClass': mainClass
		}));

		//- create a Path for the HXML File
		var bfp:Path = (_tdir + 'build.hxml');
		// create the build-file object
		var rbf:BuildFile = BuildFile.fromData( bd );

		//- Write the HXML Code into the HXML File
		Fs.write(bfp, rbf.toHxml());

		//- Move to the temp-dir
		Sys.setCwd( bfp.directory );

		//- Tell Haxe to compile that HXML File
		Sys.command('haxe', [bfp.name]);

		var cfile:File = new File(bd.buildPath);

		/* if we've built our file successfully */
		if (Fs.exists( bd.buildPath )) {
			var data:String = sys.io.File.getContent( bd.buildPath );
			//sys.io.File.saveContent(bd.buildPath, preamble(data));
			var blob = blobExpr(bd.buildPath.name, preamble(data));

			// delete the hxml file
			Fs.deleteFile( bfp.name );
			// delete the main class file
			Fs.deleteFile( mcFile.path.name );

			// return to our original working directory
			Sys.setCwd( _cwd );

			return blob;
		} 
		
		/* if the file was not created, for some reason */
		else {
			// delete the hxml file
			Fs.deleteFile( bfp.name );
			// delete the main class file
			Fs.deleteFile( mcFile.path.name );

			// return to our original working directory
			Sys.setCwd( _cwd );

			// alert the user that the build failed
			Context.error('Compilation of $bfp failed!', Context.currentPos());
			return macro throw 'WorkerError: Worker compilation failed and shit';
		}
	}

#if macro
	
	/**
	  * Convert [v] to an Expr
	  */
	public static function toExpr(v : Dynamic) {
		return Context.makeExpr(v, Context.currentPos());
	}

	/**
	  * Loads the contents of a File, as a ByteArray
	  */
	public static function loadFile(path : String) {
		try {
			var data:ByteArray = sys.io.File.getBytes(path);
			return data;
		} catch (err : String) {
			return haxe.macro.Context.error(err, Context.currentPos());
		}
	}

	/**
	  * Alter the script's contents to allow it to execute
	  */
	private static function preamble(code : String):String {
		var result:String = '';
		result += 'var exports = {};\n';
		result += code;
		return result;
	}

	/**
	  * Get the target build-path
	  */
	public static function getMainBuildPath():Path {
		var buildFilePath:Path = Path.sum(Sys.getCwd(), 'build.hxml');
		var buildFile:BuildFile = loadBuildFile( buildFilePath );
		var buildData:BuildData = buildFile.getData()[0];
		var result = buildData.buildPath;
		if (result == null)
			throw 'WorkerError: Cannot infer current build-path!';
		return result;
	}

	/**
	  * Load a build-file
	  */
	public static function loadBuildFile(path : Path):BuildFile {
		var reader = new Reader();
		return reader.read(loadFile( path ));
	}

	/**
	  * Build an ExprOf<Blob>
	  */
	public static function blobExpr(name:String, data:ByteArray, ?type:String):ExprOf<Blob> {
		if (type == null) {
			type = Mimes.getMimeType(new Path(name).extension);
		}

		var encoded:String = data.base64Encode();
		var decoded:ExprOf<ByteArray> = macro tannus.io.ByteArray.fromBase64( $v{encoded} );
		return macro new tannus.io.Blob($v{name}, $v{type}, $decoded);
	}
	
	/**
	  * Templatify WorkerMain.hx
	  */
	public static function buildWorkerMainTemplate(paths : Array<Path>):Template {
		//- Path to WorkerMain.hx
		var wmp:Path;
		for (p in paths) {
			var tp:Path = (p + '/tannus/concurrent/js/WorkerMain.hx');
			if (Fs.exists( tp )) {
				wmp = tp;
				break;
			}
		}

		if (wmp != null) {
			var content:String = Fs.read( wmp );
			content = content.replace('package tannus.concurrent.js', 'package ');
			return new Template( content );
		} else throw 'WorkerMain.hx could not be found :c';
	}
#end
}
