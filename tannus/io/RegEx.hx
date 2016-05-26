package tannus.io;

import tannus.ds.Maybe;

using StringTools;

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

			while ( matched ) {
				try {
					var p = e.matched( i );
					if (p == null) {
						matched = false;
						break;
					}
					parts.push( p );
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
	  * Extract only the grouped matches
	  */
	public inline function extractGroups(str:String, n:Int=0):Null<Array<String>> {
		return search(str)[0].slice(1);
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
	  * Replace each match with some String
	  */
	public function replace(rtext:String, text:String) {
		return this.map(rtext, function(e:EReg):String {
			var i:Int = 0;
			var whole:Null<String> = null;
			var subs:Array<String> = [];
			while (true) {
				try {
					var s:String = this.matched(i++);
					if (whole == null)
						whole = s;
					else
						subs.push( s );
				}
				catch (err : Dynamic) {
					break;
				}
			}
			var _t:String = text;
			for (ii in 0...subs.length) {
				_t = _t.replace('{{$ii}}', subs[ii]);
			}
			return _t;
		});
	}

	/**
	  * Cast to a (String -> Bool)
	  */
	@:to
	public function toTester():String->Bool {
		return (this.match.bind(_));
	}
}
