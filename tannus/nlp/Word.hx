package tannus.nlp;

import tannus.io.ByteArray;

import Math.*;
import tannus.math.TMath.*;

using StringTools;
using tannus.ds.StringUtils;

@:forward(length)
abstract Word (String) from String {
	/* Constructor Function */
	public inline function new(s : String):Void {
		this = s;
	}

/* === Instance Methods === */

	/* convert to lowercase */
	public inline function lower():Word {
		return new Word(this.toLowerCase());
	}

	/* convert to uppercase */
	public inline function upper():Word {
		return new Word(this.toUpperCase());
	}

	/* capitalize [this] Word */
	public inline function capitalize():Word {
		return new Word(this.capitalize());
	}

	/* convert to a String */
	@:to
	public inline function toString():String {
		return this;
	}

	/**
	  * convert to ByteArray
	  */
	@:to
	public inline function bytes():ByteArray {
		return ByteArray.ofString( this );
	}

	/**
	  * Compare to [other] using levenshtein algorithm
	  */
	public function levenshtein(other : Word):Int {
		if (this.empty()) return other.length;
		if (other.length == 0) return this.length;

		var l = bytes();
		var r = other.bytes();

		var matrix:Array<Array<Int>> = new Array();
		var i:Int = 0;
		while (i < r.length) {
			matrix[i] = [i];
			i++;
		}

		var j:Int = 0;
		while (j < l.length) {
			matrix[0][j] = j;
			j++;
		}

		i = 1;
		while (i < r.length) {
			j = 1;
			while (j < l.length) {
				if (r[i - 1] == l[j - 1]) {
					matrix[i][j] = matrix[i -1][j - 1];
				}
				else {
					matrix[i][j] = cast min(matrix[i-1][j-1]+1, min(matrix[i][j-1]+1, matrix[i-1][j]+1));
				}
				j++;
			}
			i++;
		}
		return matrix[r.length - 1][l.length - 1];
	}

/* === Instance Fields === */

	/* check whether [this] Word is lowercase */
	public var islower(get, never):Bool;
	private inline function get_islower():Bool {
		return (this.toLowerCase() == this);
	}

	/* check whether [this] Word in uppercase */
	public var isupper(get, never):Bool;
	private inline function get_isupper():Bool {
		return (this.toUpperCase() == this);
	}

	/* check whether [this] Word is capitalized */
	public var iscapitalized(get, never):Bool;
	private inline function get_iscapitalized():Bool {
		return (this.capitalize() == this);
	}
}
