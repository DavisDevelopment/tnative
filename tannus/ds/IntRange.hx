package tannus.ds;

import tannus.ds.Range;
import tannus.ds.IComparable;

class IntRange extends Range<Int> implements IComparable<IntRange> {
	/**
	  * Create and return an iterator from [min] to [max]
	  */
	public inline function iterator() return new IntIterator(min, max);
}
