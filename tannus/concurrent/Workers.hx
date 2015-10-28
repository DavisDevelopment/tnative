package tannus.concurrent;

import tannus.io.Byte;
import tannus.io.ByteArray;
import tannus.io.Ptr;
import tannus.io.Getter;
import tannus.sys.File;
import tannus.sys.Directory;
import tannus.sys.FileSystem in Fs;
import tannus.sys.Path;
import tannus.io.Blob;
import tannus.internal.BuildFile;

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
		var ebf = toExpr( bf );

		return macro (tannus.concurrent.js.Boss.create($ebf));
	}

	/**
	  * Build a Worker
	  */
	public static macro function buildBlob(buildFile:String):ExprOf<tannus.io.Blob> {
		var f:File = new File(buildFile);
		var bytes = f.read();
		var reader = new tannus.format.hxml.Reader();
		var buildf = reader.read( bytes );
		var bd = buildf.getData()[0];
		var mainClass:String = '';

		var _cwd:Path = Sys.getCwd();
		_cwd = _cwd.normalize();
		var _tdir:Path = tannus.TSys.tempDir();
		_tdir = _tdir.normalize();
		
		//- alter the paths in the build-file to continue pointing to their intended location
		bd.buildPath = (_tdir + bd.buildPath.name).normalize();
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
		//- Write the HXML Code into the HXML File
		var hxf:File = new File(bfp);
		hxf.write(BuildFile.fromData( bd ).toHxml());

		//- Move to the temp-dir
		Sys.setCwd( bfp.directory );

		//- Tell Haxe to compile that HXML File
		Sys.command('haxe', [bfp]);

		//- Find the built File
		var rfile:File = new File(bd.buildPath.normalize());
		var ebytes:ExprOf<ByteArray>;
		
		if (rfile.exists) {
			var content = rfile.read();
			rfile.delete();
			hxf.delete();
			mcFile.delete();
			var encoded:String = content.toBase64();
			var exprEncoded = Context.makeExpr(encoded, Context.currentPos());
			Sys.setCwd(_cwd);
			ebytes = (macro tannus.io.ByteArray.fromBase64($exprEncoded));
		} 
		else {
			Sys.setCwd(_cwd);
			Context.error('Compilation of $bfp failed!', Context.currentPos());
			ebytes = (macro tannus.io.ByteArray.fromString(''));
		}

		var ename = Context.makeExpr(bd.buildPath.name, Context.currentPos());
		var etype = Context.makeExpr(tannus.sys.Mimes.getMimeType(bd.buildPath.extension), Context.currentPos());
		
		return macro new tannus.io.Blob($ename, $etype, $ebytes);
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
