package tannus.io;

import tannus.io.Byte;
import tannus.io.ByteArray;
import tannus.io.Ptr;
import tannus.io.Signal;

class TerminalPrompt {
	/* Constructor Function */
	public function new(q:String, ?_answer:Ptr<ByteArray>):Void {
		query = q;

		if (_answer != null) {
			answer = _answer;
		} else {
			var _a:ByteArray = ' ';
			answer = Ptr.create(_a);
		}

		answered = new Signal();
	}

/* === Instance Fields === */

	//- The prompt displayed to the user
	public var query : String;

	//- A pointer to the ByteArray we get back
	public var answer : Ptr<ByteArray>;

	//- Signal which is broadcast when we receive an answer
	public var answered : Signal<ByteArray>;

/* === Instance Methods === */

	/**
	  * Method which actually performs the prompt, and gets the value
	  */
	public function get():Void {
		#if !node
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
				//- repoint [answer] to [inp]
				answer.set( inp );

				answered.call(cast inp);
			}
			//- if we got no input
			else {
				//- ask again
				get();
			}
		#else
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
					answer.set( data );
					answered.call( data );
				}
			});
		#end
	}

	/**
	  * Await a successful answer
	  */
	public function await(f : ByteArray->Void):Void {
		answered.once( f );
	}
}
