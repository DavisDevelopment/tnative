package tannus.internal;

import tannus.io.Byte;
import tannus.io.ByteArray;
import tannus.io.Ptr;
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
	public static macro function readJSON(path : String):ExprOf<{}> {
		var sdata:String = loadFile( path );
		var data:Dynamic = haxe.Json.parse( sdata );

		return toExpr( data );
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
