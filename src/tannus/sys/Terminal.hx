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
	public static function prompt(msg:String, ?tester:String->Bool):StringPromise {
		#if node
			var rl:Dynamic = require('readline');
			var opt:Object = {'input':process.stdin, 'output':process.stdout};

			return Promise.create({
				function ask():Void {
					var failed:Bool = false;
					var i:Dynamic = rl.createInterface( opt );
					i.question(msg, function( answer ) {
						if (tester != null) {
							if (tester(answer)) {
								return answer;
							}
							else {
								failed = true;
							}
						}
						else {
							return answer;
						}

						i.close();

						if (failed)
							ask();
					});
				}
				ask();
			}).string();
		#else
			#error
		#end
	}
}
