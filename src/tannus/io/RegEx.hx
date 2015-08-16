package tannus.io;

import tannus.ds.Maybe;

@:forward
/* Abstraction layer on top of the EReg type */
abstract RegEx (EReg) from EReg to EReg {
	/* Constructor Function */
	public inline function new(pattern : EReg):Void {
		this = pattern;
	}

/* === Instance Methods === */

	/**
	  * Get an Array of all substrings of [text] which fit [this] pattern
	  */
	public function matches(text : String):Array<Array<String>> {
		var ma:Array<Array<String>> = new Array();

		this.map(text, function(e:EReg) {
			var parts:Array<String> = new Array();
			var i:Int = 0;
			var matched:Bool = true;

			while (matched) {
				try {
					parts.push(e.matched(i));
					i++;
				} 
				catch (err : Dynamic) {
					matched = false;
					break;
				}
			}

			ma.push( parts );
			return '';
		});

		return ma;
	}

	/**
	  * Alias to 'matches'
	  */
	public inline function search(s : String):Array<Array<String>> 
		return matches( s );

	/**
	  * Extract the first [x] matches of [this] Pattern, if any
	  */
	public inline function extract(str:String, n:Int=0):Null<Array<String>> {
		return (search(str)[n]);
	}

	/**
	  * Return an Array of RegExMatchs
	  */
	public function findAll(s : String):Array<Dynamic> {
		var all:Array<Dynamic> = new Array();
		this.map(s, function(e : EReg) {
			var pos = e.matchedPos();

			all.push({
				'str' : s,
				'pos' : e.matchedPos()
			});

			return s;
		});
		return all;
	}

	/**
	  * Cast to a (String -> Bool)
	  */
	@:to
	public function toTester():String->Bool {
		return (this.match.bind(_));
	}
}
