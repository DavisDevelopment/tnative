package tannus.nlp;

import tannus.nlp.Lexer;
import tannus.nlp.Word;

import tannus.io.RegEx;

using Lambda;
using StringTools;
using tannus.ds.StringUtils;
using tannus.ds.ArrayTools;

class Words {
	/* Constructor Function */
	public function new(d : Array<Word>):Void {
		data = d;
	}

/* === Instance Methods === */

	/**
	  * Get the Word at index [i]
	  */
	public function get(i : Int):Null<Word> {
		return data[ i ];
	}

	/**
	  * Get the number of times that [w] occurs in [this]
	  */
	public function count(w : Word):Int {
		return data.count(function(cw) return (w == cw));
	}

	/**
	  * Check whether [this] Bag has the given Word
	  */
	public function has(w : Word):Bool {
		return data.has(w);
	}

	/**
	  * Add a Word to [this] Bag
	  */
	public function add(w : Word):Void {
		data.push( w );
	}

	/**
	  * Remove a Word from [this] List
	  */
	public function remove(w : Word):Bool {
		return data.remove(w);
	}

	/**
	  * Iterate over all Words
	  */
	public function iterator():Iterator<Word> {
		return data.iterator();
	}

	/**
	  * Manipulate the Words in [this] Bag
	  */
	public function map(f : Word->Word):Words {
		return new Words(data.map(f));
	}

	/**
	  * Get a filtered subset of [this] Bag
	  */
	public function filter(f : Word->Bool):Words {
		return new Words(data.filter(f));
	}

	/**
	  * Get the 'sum' of [this] Bag and another
	  */
	public function plus(other : Words):Words {
		return new Words(data.concat(other.data));
	}

	/**
	  * Subtract another Bag from [this] one
	  */
	public function minus(other : Words):Words {
		return new Words(data.without(other.data));
	}

	/**
	  * Get the union of [this] set and another
	  */
	public function union(other : Words):Words {
		return new Words(data.union(other.data));
	}

	/**
	  * Join all words with [sep]
	  */
	public function join(sep : String):String {
		return (data.join( sep ));
	}

/* === Instance Fields === */

	private var data : Array<Word>;

/* === Static Methods === */

	/**
	  * Create a wordbag from a String
	  */
	public static function create(s : String):Words {
		return new Words(Lexer.tokenizeString(s));
	}

	/* create an empty word-set */
	public static function empty():Words {
		return new Words([]);
	}
}
