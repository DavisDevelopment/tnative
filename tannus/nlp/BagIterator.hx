package tannus.nlp;

import tannus.nlp.Words;
import tannus.nlp.Word;
import tannus.nlp.Bag;

@:access(tannus.nlp.Bag)
class BagIterator {
	/* Constructor Function */
	public function new(b : Bag):Void {
		bag = b;
		index = 0;
		current = null;
	}

/* === Instance Methods === */

	/**
	  * Determine whether there is a next value
	  */
	public function hasNext():Bool {
		if (current == null || !current.hasNext()) {
			if (index >= bag.sets.length-1)
				return false;
			else {
				current = bag.set(++index).iterator();
				return hasNext();
			}
		}
		else {
			return current.hasNext();
		}
	}

	/**
	  * Get the next value
	  */
	public function next():Word {
		return current.next();
	}

/* === Instance Fields === */

	private var bag : Bag;
	private var index : Int;
	private var current : Null<Iterator<Word>>;
}
