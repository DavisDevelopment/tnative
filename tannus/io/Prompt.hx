package tannus.io;

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
		#if (cpp || neko || cs || php || java)

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
/* === Computed Instance Fields === */


/* === Instance Fields === */

	private var message : String;
}
