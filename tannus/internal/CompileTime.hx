package tannus.internal;

import tannus.io.Byte;
import tannus.io.ByteArray;
import tannus.io.Ptr;
import tannus.io.Getter;
import tannus.sys.File;
import tannus.sys.Directory;
import tannus.sys.Path;
import tannus.io.Blob;

import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Format;
import haxe.Json;

using StringTools;
using Lambda;
using haxe.macro.ExprTools;

/**
  * Class of utility macro methods
  */
class CompileTime {

	/**
	  * Embed the Build Date
	  */
	public static macro function buildDate():ExprOf<Date> {
		var d = Date.now();
		var year = toExpr(d.getFullYear());
		var month = toExpr(d.getMonth());
		var day = toExpr(d.getDate());
		var hours = toExpr(d.getHours());
		var minutes = toExpr(d.getMinutes());
		var seconds = toExpr(d.getSeconds());

		return macro new Date($year, $month, $day, $hours, $minutes, $seconds);
	}

	/**
	  * Measure how long it takes to execute the given expression
	  */
	public static macro function time(action : Expr):ExprOf<Int> {
		var ctime = macro (Date.now().getTime());
		return macro (function() {
			var __now = $ctime;
			$action;
			return Std.int($ctime - __now);
		}());
	}

	/**
	  * User name
	  */
	public static macro function getUserName():ExprOf<String> {
		var p = new sys.io.Process('whoami', []);
		var res = p.stdout.readLine();
		return Context.makeExpr(res, Context.currentPos());
	}

	/**
	  * Parse and execute the given String
	  */
	public static macro function execute(code : String):Expr {
		var e:Expr = Context.parse(code, Context.currentPos());
		return e;
	}

	/**
	  * Inline an entire File as Binary data
	  */
	public static macro function readFile(path : String):ExprOf<ByteArray> {
		var data:ByteArray = loadFile( path );
		var enc:ExprOf<String> = toExpr(data.toBase64());

		return macro tannus.io.ByteArray.fromBase64($enc);
	}

	public static macro function readLines(path : String):ExprOf<Array<String>> {
		var data:String = loadFile(path);
		var lines:ExprOf<Array<String>> = toExpr(data.split('\n'));

		return macro $lines;
	}

	/**
	  * Inline a File as a Blob
	  */
	public static macro function readBlob(path : String):ExprOf<Blob> {
		var data:ByteArray = loadFile( path );
		var enc:ExprOf<String> = toExpr(data.toBase64());
		var name:Path = path;
		name = name.name;
		var ename:ExprOf<String> = toExpr( name );

		var mime:ExprOf<String> = toExpr(tannus.sys.Mimes.getMimeType(${name.extension}));
		
		return macro (new tannus.io.Blob(
			$ename, 
			$mime, 
			(tannus.io.ByteArray.fromBase64($enc))
		));
	}

	/**
	  * Inline a JSON File
	  */
	public static macro function readJSON(path:String, ?eRelToCurFile:ExprOf<Bool>):ExprOf<{}> {
		var rel2CurrentFile:Bool = false;
		if (eRelToCurFile.getValue() == true)
			rel2CurrentFile = true;
		var sdata:String;
		if (rel2CurrentFile) {
			var cf:Path = Context.getPosInfos(Context.currentPos()).file;
			var cwd:Path = Sys.getCwd();
			var cfp:Path = (cf.absolute ? cf : (cwd + cf)).normalize();
			sdata = loadFile(cfp.directory.resolve(path).normalize());
		} else {
			sdata = loadFile( path );
		}
		var data:Dynamic = haxe.Json.parse( sdata );

		return toExpr( data );
	}

	/**
	  * Add a Resource
	  */
	public static macro function resource(path:String, ?rel:ExprOf<Bool>):ExprOf<Getter<ByteArray>> {
		var relative:Bool = false;
		if (rel != null)
			relative = cast rel.getValue();
		if (relative) {
			var curFile:Path = Context.getPosInfos(Context.currentPos()).file;
			var cwd:Path = Sys.getCwd();
			var cfp:Path = (curFile.absolute?curFile:(cwd + curFile)).normalize();
			path = cfp.directory.resolve(path).normalize();
		}
		var epath = Context.makeExpr(path, Context.currentPos());
		var f:File = new File(path);
		Context.addResource(path, f.read());
		return macro {
			new tannus.io.Getter(function() {
				return tannus.io.ByteArray.fromBytes(haxe.Resource.getBytes($epath));
			});
		};
	}

	/**
	  * Inline the result of a BuildFile as a Blob
	  */
	public static macro function inlineProgram(buildFile : String):ExprOf<tannus.io.Blob> {
		var f:File = new File(buildFile);
		var bytes = f.read();
		var reader = new tannus.format.hxml.Reader();
		var buildf = reader.read( bytes );
		var bd = buildf.getData()[0];

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
	
#end
}
