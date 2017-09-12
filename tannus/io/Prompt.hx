package tannus.io;

using StringTools;
using tannus.ds.StringUtils;

class Prompt {
	/* Constructor Function */
	public function new(msg : String):Void {
		message = msg;
	}

/* === Instance Methods === */

	/**
	  * Prompt the user for some input
	  */
	public function getLine(cb : String->Void):Void {
		//#if (cpp || neko || cs || php || java)
	    #if (sys && !python)

			/* get input/output streams */
			var inp = Sys.stdin();
			var out = Sys.stdout();

			/* display the message prompting for input */
			out.writeString( message );
			out.flush();

			/* read the input */
			var line:String = inp.readLine();
			cb( line );

		#elseif python

			var inp:String->String = python.Syntax.pythonCode('input');
			cb(inp( message ));

		#elseif node
			
			var rl:Dynamic = tannus.internal.Node.require('readline');
			var i:Dynamic = rl.createInterface({
				'input': tannus.internal.Node.process.stdin,
				'output': tannus.internal.Node.process.stdout
			});
			i.question(message, function(answer : String) {
				i.close();
				cb( answer );
			});

		#elseif js

			var win = tannus.html.Win.current;
			cb(win.prompt(message, ''));

		#else
			#error
		#end
	}
	
	/* get a line of input, and transform it */
	private function transform<T>(predicate:String->T, cb:T->Void):Void {
		getLine(function(line : String) {
			cb(predicate(line));
		});
	}
	
	/**
	  * Get an Int input
	  */
	public function getInt(cb : Int->Void):Void {
		transform(function(line : String):Int {
			line = line.trim();
			/* ensure that [line] doesn't contain a decimal point (".") */
			if (line.has('.')) {
				mismatch('Int', line);
			}
			
			// whether [line] passed all tests
			var notInt:Bool = false;
			
			try {
				// attempt to parse [line] as an Integer
				var res:Int = Std.parseInt( line );
				
				/* ensure that [res] is actually an Int */
				if (Std.is(res, Int)) {
					return res;
				}
				else {
					notInt = true;
				}
			}
			catch (error : Dynamic) {
				notInt = true;
			}
			
			/* if [line] failed any tests */
			if ( notInt ) {
				// raise an InputMismatchError
				mismatch('Int', line);
			}
			
			// placeholder return
			return -1;
		}, cb);
	}
	
	/**
	  * Get a Float input
	  */
	public function getFloat(cb : Float->Void):Void {
		transform(function(line:String):Float {
			line = line.trim();
			var failed:Bool = false;
			try {
				var res = Std.parseFloat( line );
				if (Std.is(res, Float)) {
					return res;
				}
				else {
					failed = true;
				}
			}
			catch (error : Dynamic) {
				failed = true;
			}
			if (failed) {
				mismatch('Float', line);
			}
			return -1;
		}, cb);
	}
	  
/* === Instance Fields === */

	private var message : String;
	
/* === Static Methods === */

	/* raise an InputError */
	private static inline function err(msg : String):Void {
		throw 'InputError: $msg';
	}
	
	/* raise an InputMismatchError */
	private static function mismatch(expected:String, ?got:String):Void {
		var msg:String = 'InputMismatchError: Expected value of type $expected';
		if (got != null) {
			msg += ', but got "$got"';
		}
		throw msg;
	}
}
