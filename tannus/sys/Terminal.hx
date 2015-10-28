package tannus.sys;

import tannus.io.Ptr;
import tannus.io.Signal;
import tannus.ds.Maybe;
import tannus.ds.Object;
import tannus.ds.Promise;
import tannus.ds.promises.*;

#if node
import tannus.internal.Node;
import tannus.internal.Node.require;
import tannus.internal.Node.process;
#end

class Terminal {
	/**
	  * Prompt user for command-line input
	  */
	public static function prompt(msg:String, ?tester:String->Bool, ?callback:String->Void):Void {
		var cb:String->Void = (callback!=null?callback:(function(s) null));
		#if node
			var rl:Dynamic = require('readline');
			var opt:Object = {'input':process.stdin, 'output':process.stdout};

			(function() {
				function ask():Void {
					var failed:Bool = false;
					var i:Dynamic = rl.createInterface( opt );
					i.question(msg, function( answer ) {
						if (tester != null) {
							if (tester(answer)) {
								cb( answer );
							}
							else {
								failed = true;
							}
						}
						else {
							cb(answer);
						}

						i.close();

						if (failed)
							ask();
					});
				}
				ask();
			}());

		#elseif python
			function ask():Void {
				var failed:Bool = false;
				var answer:String = cast (untyped python.Syntax.pythonCode('input(msg)'));
				if (tester != null) {
					if (tester(answer))
						cb( answer );
					else
						failed = true;
				}
				else {
					cb( answer );
				}
				if (failed)
					ask();
			}
			ask();

		#else
			#error
		#end
	}
}
