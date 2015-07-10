package tannus.io;

import tannus.io.Byte;
import tannus.io.ByteArray;
import tannus.io.Ptr;
import tannus.io.Signal;
import tannus.ds.Promise;
import tannus.ds.promises.StringPromise;

class TerminalPrompt {
	/* Constructor Function */
	public function new(q : String):Void {
		query = q;
		answered = new Signal();
		answer = null;

		answered.on(function(data : ByteArray) {
			answer = data.toString();
		});
	}

/* === Instance Fields === */

	//- The prompt displayed to the user
	public var query : String;

	//- A pointer to the ByteArray we get back
	public var answer : Null<String>;

	//- Signal which is broadcast when we receive an answer
	public var answered : Signal<ByteArray>;

/* === Instance Methods === */

	/**
	  * Method which actually performs the prompt, and gets the value
	  */
	public function get():Void {
		#if (js && node)

			//- get reference to [process.stdout]
			var stdout:Dynamic = untyped __js__('process.stdout');
			//- get reference to [process.stdin]
			var stdin:Dynamic = untyped __js__('process.stdin');

			//- Display the prompt message
			stdout.write( query );

			//- open up the [stdin] Stream
			stdin.resume();
			stdin.setEncoding('utf8');
			
			stdin.on('data', function(_dat:Dynamic):Void {
				var data:ByteArray = ByteArray.fromString( _dat );
				data.pop();
				
				stdin.pause();
				if (!data.empty) {
					answered.call( data );
				}
			});

		#elseif (python || php || neko || cpp || cs || java)

			var stdout = Sys.stdout();
			var stdin = Sys.stdin();

			stdout.writeString( query );
			stdout.flush();

			var inp:ByteArray;
			while (true) {
				try {
					var s:String = stdin.readLine();
					trace( s );
					inp = s;
					break;
				} catch (e : Dynamic) {
					continue;
				}
			}

			if (inp.length > 0) {
				answered.call(cast inp);
			}
			//- if we got no input
			else {
				//- ask again
				get();
			}
		#end
	}

	/**
	  * Await a successful answer
	  */
	public function await(f : ByteArray->Void):Void {
		answered.once( f );
		get();
	}

/* === Class Methods === */

	/**
	  * Create and return a Promise for an answer to a prompt
	  */
	public static function ask(question : String):StringPromise {
		var p = new TerminalPrompt(question);
		return (Promise.create({
			p.await(function(data : ByteArray) {
				return p.answer;
			});
		}, false).string());
	}
}
