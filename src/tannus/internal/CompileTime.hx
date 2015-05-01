package tannus.internal;

import tannus.io.Byte;
import tannus.io.ByteArray;
import tannus.io.Ptr;
import tannus.sys.File;

import haxe.macro.Context;
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

	/**
	  * Inline a File as an Array of lines
	  */
	public static macro function readLines(path : String):ExprOf<Array<String>> {
		var data:String = loadFile(path);
		var lines:ExprOf<Array<String>> = toExpr(data.split('\n'));

		return macro ($lines);
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
		var f:File = path;

		try {
			var data = f.read();
			return data;
		} catch (err : String) {
			return haxe.macro.Context.error(err, Context.currentPos());
		}
	}

#end
}
