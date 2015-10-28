package tannus.ds;

import tannus.ds.Range;

class IntRange extends Range<Int> {
	/**
	  * Create and return an iterator from [min] to [max]
	  */
	public inline function iterator() return new IntIterator(min, max);
}
