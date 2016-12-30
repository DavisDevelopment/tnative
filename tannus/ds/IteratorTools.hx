package tannus.ds;

import tannus.io.*;

class IteratorTools {
	/**
	  * 'map' an Iterator, like one would an Array
	  */
	public static inline function map<A, B>(iterator:Iterator<A>, mapper:A->B):Iterator<B> {
		return new FunctionalIterator(iterator, mapper);
	}
}

private class FunctionalIterator<A, B> {
	public inline function new(iterator:Iterator<A>, mapper:A->B):Void {
		i = iterator;
		f = mapper;
	}

	public inline function hasNext():Bool return i.hasNext();
	public inline function next():B return f(i.next());

	private var i:Iterator<A>;
	private var f:A -> B;
}
