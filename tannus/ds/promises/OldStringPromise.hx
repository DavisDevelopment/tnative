package tannus.ds.promises;

import tannus.ds.Promise;
import tannus.ds.promises.*;
import tannus.ds.EitherType;
import tannus.io.RegEx;

import haxe.macro.Expr;
import haxe.macro.Context;

using StringTools;
using haxe.macro.ExprTools;
class StringPromise extends Promise<String> {
/* === Instance Methods === */

	/**
	  * Get the character at index [i] on [this] String, if there is one
	  */
	public function charAt(i : Int):StringPromise {
		var res:StringPromise = sp(res, err, {
			then(function(s) 
				res(s.charAt(i))
			);
			unless( err );
		});
		attach( res );
		return res;
	}

	/**
	  * Get the byte-code of the character at index [i]
	  */
	public function charCodeAt(i : Int):Promise<Int> {
		var res = charAt( i ).transform(function(c : String) return c.charCodeAt(0));
		attach( res );
		return res;
	}

	/**
	  * Split [this] String into an Array of Strings
	  */
	public function split(delimiter : String):ArrayPromise<String> {
		var res:ArrayPromise<String> = Promise.create({
			then(function( s ) {
				return s.split(delimiter);
			});

			unless(function( err ) {
				throw err;
			});
		}).array();
		attach( res );
		return res;
	}

	/**
	  * Obtain a sub-string of [this] String when it arrives
	  */
	public function substr(pos:Int, ?len:Int):StringPromise {
		var res:StringPromise = sp(yes, naw, {
			then(function(data : String) {
				var sub:String = data.substr(pos, len);
				
				yes( sub );
			});

			unless( naw );
		});
		attach( res );
		return res;
	}

	/**
	  * Obtain a sub-string of [this] String when it arrives
	  */
	public function substring(start:Int, end:Int):StringPromise {
		var res:StringPromise = sp(yes, naw, {
			then(function(data : String) {
				var sub:String = data.substring(start, end);
				
				yes( sub );
			});

			unless( naw );
		});
		attach( res );
		return res;
	}

	/**
	  * Obtain [this] String, in all UpperCase letters, when it arrives
	  */
	public function toUpperCase():StringPromise {
		var res:StringPromise = sp(yes, naw, {
			then(function(s) yes(s.toUpperCase()));
			unless( naw );
		});
		attach( res );
		return res;
	}

	/**
	  * Obtain [this] String, in all LowerCase letters, when it arrives
	  */
	public function toLowerCase():StringPromise {
		var res:StringPromise = sp(yes, naw, {
			then(function(s) yes(s.toLowerCase()));
			unless( naw );
		});
		attach( res );
		return res;
	}

	/**
	  * Obtain [this] String, capitalized, when it arrives
	  */
	public function capitalize():StringPromise {
		var res:StringPromise = Promise.create({
			then(function( s ) {
				var chars = s.split('');
				var first = chars.shift().toUpperCase();
				var rest = chars.join('').toLowerCase();
				return (first + rest);
			});

			unless(function(err) throw err);
		}).string();
		attach(res);
		return res;
	}

	/**
	  * Check whether [this] String begins with substring [start]
	  */
	public function startsWith(start : EitherType<String, Promise<String>>):BoolPromise {
		var res:BoolPromise = new BoolPromise(function(reply, reject) {
			then(function(data : String) {
				switch (start.type) {
					/* Regular String */
					case Left( str ):
						reply(data.startsWith(str));

					/* String Promise */
					case Right( _pstr ):
						var pstr = _pstr.string();
						pstr.then(function( str ) {
							reply(data.startsWith(str));
						});
				}
			});

			unless( reject );
		});

		attach( res );

		return res;
	}

	/**
	  * Check whether [this] String ends with substring [end]
	  */
	public function endsWith(end : EitherType<String, Promise<String>>):BoolPromise {
		var res:BoolPromise = new BoolPromise(function(reply, reject) {
			then(function(data : String) {
				switch (end.type) {
					/* Regular String */
					case Left( str ):
						reply(data.endsWith(str));

					/* String Promise */
					case Right( _pstr ):
						var pstr = _pstr.string();
						pstr.then(function( str ) {
							reply(data.endsWith(str));
						});
				}
			});

			unless( reject );
		});

		attach( res );

		return res;
	}

	/**
	  * Trim leading whitespace off of [this] String
	  */
	public function ltrim():StringPromise {
		var lt:StringPromise = transform(function(s) return s.ltrim()).string();
		attach( lt );
		return lt;
	}

	/**
	  * Trim trailing whitespace off of [this] String
	  */
	public function rtrim():StringPromise {
		var rt:StringPromise = transform(function(s) return s.rtrim()).string();
		attach( rt );
		return rt;
	}

	/**
	  * Trim leading AND trailing whitespace off of [this] String
	  */
	public function trim():StringPromise {
		var trimmed:StringPromise = transform(function(s) return s.trim()).string();
		attach(trimmed);
		return trimmed;
	}

	/**
	  * Validate [this] String against a regular expression
	  */
	public function match(pattern : RegEx):BoolPromise {
		var res:BoolPromise = transform(function(s) {
			return (pattern.match(s));
		}).bool();
		attach( res );
		return res;
	}

/* === Class Methods === */

	/**
	  * Macro stuff to quickly create a new StringPromise
	  */
	public static macro function sp(accept, reject, action):ExprOf<StringPromise> {
		var yep = macro accept;
		var nop = macro reject;

		function mapper(expr : Expr):Expr {
			if (expr.expr.equals(accept.expr)) {
				return yep;
			}
			else if (expr.expr.equals(reject.expr)) {
				return nop;
			}
			else {
				return expr.map(mapper);
			}
		}

		action = action.map( mapper );

		return macro new StringPromise(function(accept, reject) {
			$action;
		});
	}
}
