package tannus.nlp;

import tannus.ds.Dict;
import tannus.ds.tuples.Tup2;

import tannus.nlp.Words;
import tannus.nlp.Word;
import tannus.nlp.BagIterator;

using Lambda;
using tannus.ds.ArrayTools;
using StringTools;
using tannus.ds.StringUtils;

@:access(tannus.nlp.Words)
class Bag {
	/* Constructor Function */
	public function new():Void {
		sets = new Array();
	}

/* === Instance Methods === */

	/**
	  * Add a new Word set to [this] Bag
	  */
	public function addSet(s : Words):Void {
		sets.push( s );
	}

	/**
	  * Get the Word set at index [i]
	  */
	public function set(i : Int):Null<Words> {
		return sets[i];
	}

	/**
	  * Remove the given Work from all data sets
	  */
	public function remove(word : Word):Void {
		for (s in sets)
			s.remove(word);
	}

	/**
	  * Remove the given set from all sets
	  */
	public function purge(rs : Words):Void {
		for (s in sets)
			for (w in rs)
				s.remove(w);
	}

	/**
	  * Iterate over all Word Sets
	  */
	public function iterator():Iterator<Words> {
		return sets.iterator();
	}

	/**
	  * Iterate over all Words
	  */
	public function words():Iterator<Word> {
		return new BagIterator(this);
	}

	/**
	  * Find words which can be found in all sets
	  */
	public function common():Words {
		var res:Words = sets[0];
		for (s in sets)
			res = res.union(s);
		return res;
	}

	/**
	  * Get the total number of occurrences of [word] in [this] Bag
	  */
	public function count(word : Word):WordCount {
		var total:Int = 0;
		var byset:Int = 0;
		for (s in sets) {
			var found:Bool = false;
			var sc = s.count( word );
			total += sc;
			if (total > 0)
				byset++;
		}
		return new WordCount(total, byset);
	}

	/**
	  * Get a set of the Words which can be found in the same set at [word]
	  */
	public function neighbors(word : Word):Words {
		var results:Array<CountedWord> = new Array();
		var map:Dict<Word, WordCount> = new Dict();
		function getCount(w : Word) {
			var c = map[w];
			if (c == null) {
				c = new WordCount(0, 0);
				map[w] = c;
				var cw = new CountedWord(w, c);
				results.push( cw );
			}
			return c;
		}
		for (s in sets) {
			if (s.has(word)) {
				var counted:Words = new Words([word]);
				for (w in s) {
					var c = getCount( w );
					if (!counted.has(w)) {
						counted.add( w );
						c.sets += 1;
					}
					c.total += 1;
				}
			}
		}
		results.sort(function(a, b) {
			return (b.count.total - a.count.total);
		});
		var nset = new Words([for (cw in results) cw.word]);
		nset.remove(word);
		return nset;
	}

	/**
	  * Get a Dict of all Words and their occurrences
	  */
	private function all_counts():Dict<Word, WordCount> {
		var result:Dict<Word, WordCount> = new Dict();
		for (s in sets) {
			var counted:Words = Words.empty();
			for (word in s) {
				var count = result[word];
				if (count == null)
					count = result[word] = new WordCount(0, 0);

				if (!counted.has(word)) {
					count.sets += 1;
					counted.add( word );
				}

				count.total += 1;
			}
		}
		return result;
	}

	/**
	  * Get an Array of CountedWords
	  */
	public function countAll():Array<CountedWord> {
		var dict = all_counts();
		var result:Array<CountedWord>;
		result = [for (p in dict.iterator()) new CountedWord(p.key, p.value)];
		return result;
	}

	/**
	  * Get the top-[n] Words, by frequency
	  */
	public function topTotal(n : Int):Words {
		var call = countAll();
		call.sort(function(a, b) {
			return (b.count.total - a.count.total);
		});
		call = call.slice(0, n);
		var res:Words = new Words([for (cw in call) cw.word]);
		return res;
	}

/* === Instance Fields === */

	private var sets : Array<Words>;
}

abstract CountedWord (Tup2<Word, WordCount>) {
	public inline function new(word:Word, count:WordCount):Void {
		this = new Tup2(word, count);
	}

	public var word(get, never):Word;
	private inline function get_word() return this._0;

	public var count(get, never):WordCount;
	private inline function get_count() return this._1;
}

abstract WordCount (Tup2<Int, Int>) {
	public inline function new(totl:Int, sets:Int):Void {
		this = new Tup2(totl, sets);
	}

	public var total(get, set):Int;
	private inline function get_total() return this._0;
	private inline function set_total(v) return (this._0 = v);

	public var sets(get, set):Int;
	private inline function get_sets() return this._1;
	private inline function set_sets(v) return (this._1 = v);
}
